
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import * as chats from '../../chats/chats';

/**
 * This function send notification to all the members of a chat when a message is written
 */
export const _newMessage = functions.firestore.document('chats/{chatId}/messages/{messageId}').onCreate(async function (snapshot, context) {
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
    let text: string = doc.text ? doc.text : '';
    if (doc.images && doc.images.length) {
        text = '📷'.repeat(doc.images.length) + ' ' + text;
    }

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