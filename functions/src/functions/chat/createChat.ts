import * as functions from 'firebase-functions';
import { CallableContext } from 'firebase-functions/lib/providers/https';
import * as chatUtils from '../../chats/chats';
import * as userUtils from '../../users/users';
import { ChatInterface } from '../../models/chat';

/**
 * To create a new chat
 */
export const _createChat = functions.https.onCall(async function(data, context: CallableContext) {
    
    try {
        const users = await userUtils.userList(data.usernames);
        const userIds = users.map(function(user) {
            return user.id;
        });
        userIds.sort();
        // Check the chat doesn't exist
        const query = await chatUtils.chatsCollection.where('members', '==', userIds).get();
        if (!query.empty) {
            throw Error('Chat already exists');
        }
        // ---------- Create the chat ----------
        const chat: ChatInterface = {
            id: '',
            name: '',
            members: userIds
        };
        const documentReference = await chatUtils.chatsCollection.add(chat);
        chat.id = documentReference.id;
        if (!chat.id) {
            throw Error('Could not create the new chat');
        }
        await chatUtils.chatsCollection.doc(chat.id).update({
            'id': chat.id
        });
        // ---------- Update the users ----------
        for (const user of users ) {
            const userChatsDocumentReference = userUtils.usersCollection.doc(user.id).collection('user.public').doc('chats');
            const userChatsDocument = await userChatsDocumentReference.get();
            if (!userChatsDocument.exists) {
                await userChatsDocumentReference.set({
                    id: 'chats',
                    chats: [chat.id]
                });
            } else { 
                let userChats = userChatsDocument.data()?.chats;
                if (!userChats) {
                    userChats = [];
                }
                userChats.push(chat.id);
                userChats.sort();
                await userChatsDocumentReference.update({
                    chats: userChats
                });
            }
        };
        return {
            chatId: chat.id,
            error: ''
        };
        
    } catch (error) {
        return {
            chatId: '',
            error: error.toString()
        };
    }

});