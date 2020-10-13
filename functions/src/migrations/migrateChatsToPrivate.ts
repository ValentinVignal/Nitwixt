import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
try {admin.initializeApp();} catch(e) {} // You do that because the admin SDK can only be initialized once.

/**
 * Use to put the chats in a private field:
 * 
 * user.chats => user / private / chats.chats
 */
export const _migrateChatsToPrivate = functions.https.onRequest(async function (request, response) {
    const queryUsers = await admin.firestore().collection('users').get();
    const users: Array<FirebaseFirestore.DocumentData> = [];

    console.log('start');

    // Get all the users
    for (let i=0; i<queryUsers.docs.length; i++) {
        const user = queryUsers.docs[i].data();
        users.push(user);
    }

    console.log('got the users');

    // Add private chat
    for (let i=0; i<users.length; i++) {
        const user = users[i];
        let chats = user.chats;
        if (!chats) {
            chats = [];
            console.log(`user ${user.username} has no chat`);
        }
        chats.sort();
        await admin.firestore().collection('users').doc(user.id).collection('user.private').doc('chats').set({
            chats: chats,
            id: 'chats',
            userId: user.id,
            username: user.username
        });
        await admin.firestore().collection('users').doc(user.id).collection('private').doc('chats').delete();
    };
    console.log('add the chats');

    // Remove previous chat
    for (let i=0; i<queryUsers.docs.length; i++) {
        const queryUser = queryUsers.docs[i];
        await queryUser.ref.update({
            chats: admin.firestore.FieldValue.delete()
        });
    }

    console.log('done');

    response.send('Done');
});
