import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
try {admin.initializeApp();} catch(e) {} // You do that because the admin SDK can only be initialized once.
import * as interfaces from '../interfaces';

/**
 * 
 */
export const _addChatsDate = functions.https.onRequest(async function(request, response) {
    const queryChats = await admin.firestore().collection('chats').get();
    functions.logger.log('Start', queryChats.docs.length);

    const now = admin.firestore.Timestamp.now();

    for (let i=0; i<queryChats.docs.length; i++) {
        const chat = queryChats.docs[i].data() as interfaces.Chat;
        if (!chat.date) {
            await queryChats.docs[i].ref.update({
                date: now,
            });
        }
    }

    functions.logger.log('Done');

    response.send('Done');
});