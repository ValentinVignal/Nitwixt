
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
try {admin.initializeApp();} catch(e) {} // You do that because the admin SDK can only be initialized once.
import * as interfaces from '../../interfaces';
import * as models from '../../models';


/**
 * This function send notification to all the members of a chat when a message is written
 */
export const _onNewMessage = functions.firestore.document('chats/{chatId}/messages/{messageId}').onCreate(async function (snapshot, context) {
    functions.logger.log('---------- Start function ----------');

    const ref: FirebaseFirestore.DocumentReference = snapshot.ref;
    const message = snapshot.data() as interfaces.Message;
    const chatRef = ref.parent.parent;
    if (chatRef === null) {
        console.log(`chatRef is null`);
        return null;
    }


    const chatSnapshot: FirebaseFirestore.DocumentSnapshot = await chatRef.get()
    const chat = new models.Chat(chatSnapshot.data() as interfaces.Chat);

    // Update the correct date if people change the time of their phone
    message.date = admin.firestore.Timestamp.now();
    await ref.update({
        date: message.date
    });


    const userid = message.userid;
    let text: string = message.text ? message.text : '';
    if (message.images && message.images.length) {
        text = '📷'.repeat(message.images.length) + ' ' + text;
    }

    if (chat !== undefined) {
        // Get all the users
        const queryUsers = await admin.firestore().collection('users').where(admin.firestore.FieldPath.documentId(), 'in', chat.members).get();
        const users: interfaces.User[] = [];
        queryUsers.forEach(function(queryUser) {
            const user = queryUser.data() as interfaces.User;
            user.id = queryUser.id;
            users.push(user);
        });
        const sender = users.filter(function(user) {
            return user.id === userid;
        })[0];
        // Construct the notification message
        if (chat.members.length > 2) {
            text = `${sender.name || sender.username}: ${text}`;
        }
        const payload = {
            notification: {
                title: chat.displayName(sender),
                body: text,
                badge: '1',
                sound: 'default'
            }
        }
        users.forEach(async function(user) {
            // For all the member of the chat
            if (user.id !== userid) {
                // Don't send the notification to te one who sent the message
                const queryToken = await admin.firestore().collection('users').doc(user.id).collection('user.private').doc('pushTokens').get();
                const userPushTokens = queryToken.data() as interfaces.UserPushTokens;
                if (userPushTokens && userPushTokens.tokens) {
                    userPushTokens.tokens.forEach(function (pushToken) {
                        // For each token, send the notification
                        admin.messaging().sendToDevice(pushToken, payload).then(function (response) {
                            functions.logger.log('Successfully sent the message:', response);
                        }).catch(function (error: any) {
                            functions.logger.error('Error sending message', error);
                        });
                    });
                } else {
                    functions.logger.warn('User does not have a push token yet... id:', user.id, 'name:', user.name, 'username:', user.username);
                }
            }
        })
    } else {
        functions.logger.error('Chat is undefined');
    }
    return null;
});