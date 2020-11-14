import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
try {admin.initializeApp();} catch(e) {} // You do that because the admin SDK can only be initialized once.
import { UserPublicChats } from '../interfaces';


/**
 * Used to put the chats in a private field:
 * 
 * user / private / chats.chats => user / public / chats.chats
 */
export const _migrateChatsToPublic = functions.https.onRequest(async function (request, response) {
    const queryUserChats = await admin.firestore().collectionGroup('user.private').get();
    const usersChats: UserPublicChats[] = [];

    functions.logger.log('start', queryUserChats.docs.length);

    // Get all the users
    for (let i=0; i<queryUserChats.docs.length; i++) {
        const userChats : UserPublicChats = queryUserChats.docs[i].data() as UserPublicChats;
        usersChats.push(userChats);
    }

    functions.logger.log('got the users');

    // Add private chat
    for (let i=0; i<usersChats.length; i++) {
        const userChats = usersChats[i];
        await admin.firestore().collection('users').doc(userChats.userId).collection('user.public').doc('chats').set(userChats);
    };
    functions.logger.log('add the chats');

    for (let i=0; i<queryUserChats.docs.length; i++) {
        await queryUserChats.docs[i].ref.delete();
    }

    functions.logger.log('Done');

    response.send('Done');

});
