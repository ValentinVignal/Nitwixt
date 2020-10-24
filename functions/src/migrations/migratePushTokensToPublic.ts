import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import * as interfaces from '../interfaces';
try {admin.initializeApp();} catch(e) {} // You do that because the admin SDK can only be initialized once.


export const _migratePushTokensToPublic = functions.https.onRequest(async function (request, response) {
    const queryUsers = await admin.firestore().collection('users').get();

    functions.logger.log('Start', queryUsers.docs.length);

    for (let i=0; i<queryUsers.docs.length; i++) {
        // Get data
        const user = queryUsers.docs[i].data() as interfaces.User;
        const pushTokens = {
            id: 'pushTokens',
            userId: user.id,
            username: user.username,
            tokens: user.pushToken
        } as interfaces.UserPushTokens;

        // Create public 
        await admin.firestore().collection('users').doc(user.id).collection('user.public').doc('pushTokens').set(pushTokens);

        // Delete from user

        await admin.firestore().collection('users').doc(user.id).update({pushToken: FirebaseFirestore.FieldValue.delete()});
    }
    functions.logger.log('Done');

    response.send('Done');

});
