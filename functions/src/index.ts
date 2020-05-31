import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp();

// // Start writing Firebase Functions
// // https://firebase.google.com/docs/functions/typescript
//
// export const helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });
export const messageNotification = functions.firestore.document('chats/{chatId}/messages/{messageId}').onCreate(async function (snapshot, context) {
    console.log('---------- Start function ----------');

    const ref: FirebaseFirestore.DocumentReference = snapshot.ref;
    const doc: FirebaseFirestore.DocumentData = snapshot.data();
    const chatRef = ref.parent.parent;
    if (chatRef === null) {
        console.log(`chatRef is null`);
        return null;
    }
    const chatSnapshot: FirebaseFirestore.DocumentSnapshot = await chatRef.get()
    const chat = chatSnapshot.data();
    // console.log('doc', doc, 'chat', chat);

    const userid: string = doc.userid;
    const text: string = doc.text;

    if (chat !== undefined) {
        // Construct the notification message
        const payload = {
            notification: {
                title: `New message`,
                body: text,
                badge: '1',
                sound: 'default'
            }
        }
        const memberidsToSend: Array<String> = Object.keys(chat.members);
        // Remove the sender
        const index: number = memberidsToSend.indexOf(userid);
        if (index > -1) { memberidsToSend.splice(index, 1); }
        if (memberidsToSend.length === 0) {
            console.log('No user to send..');
            return null;
        }
        const queryUsers = await admin.firestore().collection('users').where(admin.firestore.FieldPath.documentId(), 'in', memberidsToSend).get();
        let users: Array<FirebaseFirestore.DocumentData> = [];
        queryUsers.forEach(function(queryUser) {
            let user = queryUser.data();
            user.id = queryUser.id;
            users.push(user);
        });
        // console.log('users', users);
        users.forEach(function(user) {
            // For all the member of the chat
            if (user.id !== userid) {
                // Don't send the notification to te one who sent the message
                if (user.pushToken) {
                    admin.messaging().sendToDevice(user.pushToken, payload).then(function (response) {
                        console.log('Successfully sent the message:', response);
                    }).catch(function (error) {
                        console.log('Error sending message', error);
                    });
                } else {
                    console.log('User does not have a push token yet... id:', user.id, 'name:', user.name, 'username:', user.usernmae);
                }
            }
        })
    } else {
        console.log('Chat is undefined');
    }
    return null;
});