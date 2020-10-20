import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
try {admin.initializeApp();} catch(e) {} // You do that because the admin SDK can only be initialized once.

import * as chatUtils from '../../chats/chats';
import * as userUtils from '../../users/users';
import { ChatInterface } from '../../models/chat';
import MultiValue from '../../utils/MultiValue';

enum UpdateTypes {
    members = 'members'
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
        console.warn(error.toString());
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
    const currentMemberIds = new MultiValue<string>(chat.members);

    // Get the new users
    data.value.sort();
    const newMembers = await userUtils.userList(data.value);      // Data value are the usernames
    const newMemberIds = new MultiValue<string>(newMembers.map(function(member) {
        return member.id;
    }));

    if (currentMemberIds.equals(newMemberIds)) {
        return {};
    }

    // -------------------- There are some changes --------------------
    // ---------- Update the chat ----------
    await chatDocumentReference.update({
        members: newMemberIds.values
    });

    // ---------- update the users ----------
    const idsToAdd = newMemberIds.diff(currentMemberIds);
    const idsToRemove = currentMemberIds.diff(newMemberIds);

    // ----- Add -----

    for (let index=0; index < idsToAdd.length; index++) {
        const idToAdd = idsToAdd.values[index];
        console.log('userName to add', idToAdd);
        try {
            const userChatsDocumentReference = admin.firestore().collectionGroup('user.public').where('id', '==', 'chats').where('userId', '==', idToAdd);
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
            console.warn(`Could not add the chat ${data.chatId} to user ${idToAdd} - error: ${error.toString()}`);
        }
    }

    for (let index=0; index < idsToRemove.length; index++) {
        const idToRemove = idsToRemove.values[index];
        console.log('userName to remove', idToRemove);
        try {
            const userChatsDocumentReference = admin.firestore().collectionGroup('user.public').where('id', '==', 'chats').where('userId', '==', idToRemove);
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
            console.warn(`Could not remove the chat ${data.chatId} from user ${idToRemove} - error: ${error.toString()}`);
        }
    }
    return {};
}