import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

/**
 * Use to put the chats in a private field:
 * 
 * user.chats => user / private / chats.chats
 */
export const _migrateChatsToPrivate = functions.https.onRequest(async function (request, response) {
    const queryUsers = await admin.firestore().collection('users').get();
    const users: Array<FirebaseFirestore.DocumentData> = [];
    queryUsers.forEach(function(queryUser) {
        const user = queryUser.data();
        users.push(user);
    });

    users.forEach(async function(user) {
        const chats = user.chats;
        chats.sort();
        await admin.firestore().collection('users').doc(user.id).collection('user.private').doc('chats').set({
            chats: chats,
            id: 'chats'
        });
        await admin.firestore().collection('users').doc(user.id).collection('private').doc('chats').delete();
    });
    response.send('Done');
});
