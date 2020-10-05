import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
try {admin.initializeApp();} catch(e) {} // You do that because the admin SDK can only be initialized once.

import * as chatUtils from '../../chats/chats';
import * as userUtils from '../../users/users';
import { ChatInterface } from '../../models/chat';
import MultiValue from '../../utils/Mutlivalue';
import { UserInterface } from '../../models/user';
import { user } from 'firebase-functions/lib/providers/auth';

enum UpdateTypes {
    members= 'members'
};

interface UpdateData {
    type: UpdateTypes,
    value: string[],
    chatId : string,        // String of username for members
}

export const _updateChat = functions.https.onCall(async function(data : UpdateData, context) : Promise<{error?: string}> {
    try {
        switch (data.type) {
            case (UpdateTypes.members) : {
                return await updateMembers(data);
            }
        }
    } catch (error) {
        return {
            error: error.toString()
        };
    }
});

async function updateMembers(data: UpdateData) : Promise<Object> {
    // hello im here to interrupt valentin's app code :p if you delete it you will have a bad luck
    // Get the chat
    const chatDocumentReference = chatUtils.chatsCollection.doc(data.chatId);
    const chatDocumentSnapshot = await chatDocumentReference.get();
    if (!chatDocumentSnapshot.exists) {
        return {
            error: `Chat of id ${data.chatId} doesn't exist`
        };
    }
    const chat = chatDocumentSnapshot.data() as ChatInterface;
    const currentMemberUsernames = new MultiValue<string>(chat.members);

    // Get the new users
    data.value.sort();
    const newMembers = await userUtils.userList(data.value);      // Data value are the usernames
    const newMemberUsernames = new MultiValue<string>(newMembers.map(function(member) {
        return member.username;
    }));

    if (currentMemberUsernames.equals(newMemberUsernames)) {
        return {};
    }

    // -------------------- There are some changes --------------------
    // ---------- Update the chat ----------
    await chatDocumentReference.update({
        members: data.value
    });

    // ---------- update the users ----------
    const usernamesToAdd = newMemberUsernames.diff(currentMemberUsernames);
    const usernamesToRemove = currentMemberUsernames.diff(newMemberUsernames);

    // ----- Add -----
    for (const usernameToAdd in usernamesToAdd) {
        try {
            const userChatsDocumentReference = admin.firestore().collectionGroup('user.private').where('id', '==', 'chats').where('username', '==', usernameToAdd);
            const userChatsDocumentSnapshot = await userChatsDocumentReference.get();
            if (userChatsDocumentSnapshot.empty) {
                throw Error('Empty document');
            }
            const chats = userChatsDocumentSnapshot.docs[0].data().chats as string[];
            if (chats.includes(data.chatId)) {
                throw Error('User already have the chat');
            }
            chats.push(data.chatId);
            chats.sort();
            await userChatsDocumentSnapshot.docs[0].ref.update({
                chats: chats
            });
        } catch (error) {
            console.warn(`Could not add the chat ${data.chatId} to user ${usernameToAdd} - error: ${error.toString()}`);
        }
    }

    for (const usernameToRemove in usernamesToRemove) {
        try {
            const userChatsDocumentReference = admin.firestore().collectionGroup('user.private').where('id', '==', 'chats').where('username', '==', usernameToRemove);
            const userChatsDocumentSnapshot = await userChatsDocumentReference.get();
            if (userChatsDocumentSnapshot.empty) {
                throw Error('Empty document');
            }
            let chats = userChatsDocumentSnapshot.docs[0].data().chats as string[];
            if (!chats.includes(data.chatId)) {
                throw Error('User already don\'t have the chat');
            }
            chats = chats.filter(function(chatid) {
                return chatid !== data.chatId;
            });
            chats.sort();
            await userChatsDocumentSnapshot.docs[0].ref.update({
                chats: chats
            });
        } catch (error) {
            console.warn(`Could not remove the chat ${data.chatId} from user ${usernameToRemove} - error: ${error.toString()}`);
        }
    }
    return {};
}