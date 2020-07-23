import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import * as chats from './chats';

admin.initializeApp();

// // Start writing Firebase Functions
// // https://firebase.google.com/docs/functions/typescript
//
// export const helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });

/**
 * This function send notification to all the members of a chat when a message is written
 */
export const newMessage = functions.firestore.document('chats/{chatId}/messages/{messageId}').onCreate(async function (snapshot, context) {
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

    // Update the correct date if people change the time of their phone
    doc.date = admin.firestore.Timestamp.now();
    await ref.update({
        date: doc.date
    });


    const userid: string = doc.userid;
    let text: string = doc.text;

    if (chat !== undefined) {
        // Get all the users
        const queryUsers = await admin.firestore().collection('users').where(admin.firestore.FieldPath.documentId(), 'in', chat.members).get();
        const users: Array<FirebaseFirestore.DocumentData> = [];
        queryUsers.forEach(function(queryUser) {
            const user = queryUser.data();
            user.id = queryUser.id;
            users.push(user);
        });
        const sender = users.filter(function(user) {
            return user.id === userid;
        })[0];
        // Construct the notification message
        if (chat.members.length > 2) {
            text = `${sender.name}: ${text}`;
        }
        const payload = {
            notification: {
                title: chats.nameToDisplay(chat, {}, sender),
                body: text,
                badge: '1',
                sound: 'default'
            }
        }
        users.forEach(function(user) {
            // For all the member of the chat
            if (user.id !== userid) {
                // Don't send the notification to te one who sent the message
                if (user.pushToken) {
                    user.pushToken.forEach(function(pushToken: string) {
                        // For each token, send the notification
                        admin.messaging().sendToDevice(pushToken, payload).then(function (response) {
                            console.log('Successfully sent the message:', response);
                        }).catch(function (error: any) {
                            console.log('Error sending message', error);
                        });

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



/**
 * This function deletes all the messages on the deletion of a chat
 */
export const deleteChat = functions.firestore.document('chats/{chatId}').onDelete(async function (snapshot, context) {
    console.log('---------- Start function ----------');

    // const ref: FirebaseFirestore.DocumentReference = snapshot.ref;
    const chat: FirebaseFirestore.DocumentData = snapshot.data();
    // Delete the pictures in it
    const folderPath: string = `chats/${chat.id}/`;
    const bucket = admin.storage().bucket();
    try {
        // await paths.deleteFolder(bucket, folderPath);
        await bucket.deleteFiles({
            prefix: folderPath
        });
    } catch (err) {
        console.log(`Error when deleting pictures of chat ${chat.id}, ${chat.name} :`, err)
    }
    // Delete all the messages
    const documentReferences: FirebaseFirestore.QuerySnapshot<FirebaseFirestore.DocumentData> = await admin.firestore().collection('chats').doc(chat.id).collection('messages').get();
    documentReferences.forEach(async function(documentData) {
        try {
            await documentData.ref.delete();
        } catch (err) {
            console.log(`Error when deleting chat ${chat.id}, ${chat.name}:`, err);
        }
    });
})


