import * as admin from 'firebase-admin';
try {admin.initializeApp();} catch(e) {} // You do that because the admin SDK can only be initialized once.
import * as functions from 'firebase-functions';
import { CallableContext } from 'firebase-functions/lib/providers/https';
import * as userUtils from '../../users/users';

import * as models from '../../models';
import * as interfaces from '../../interfaces';

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
        const query = await admin.firestore().collection(models.Chat.collection).where('members', '==', userIds).get();
        if (!query.empty) {
            throw Error('Chat already exists');
        }
        // ---------- Create the chat ----------
        const now = admin.firestore.Timestamp.now();
        const chat: interfaces.Chat = {
            id: '',
            name: '',
            members: userIds,
            date: now,
        };
        const documentReference = await admin.firestore().collection(models.Chat.collection).add(chat);
        chat.id = documentReference.id;
        if (!chat.id) {
            throw Error('Could not create the new chat');
        }
        await admin.firestore().collection(models.Chat.collection).doc(chat.id).update({
            'id': chat.id
        });
        // ---------- Update the users ----------
        for (let i=0; i<users.length; i++ ) {
            const user = users[i];
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