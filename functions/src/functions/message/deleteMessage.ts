import * as functions from 'firebase-functions';
import  admin from '../../admin';


/**
 * This function delete the images linked to a message
 */
export const _onDeleteMessage = functions.firestore.document('chats/{chatId}/messages/{messageId}').onDelete(async function(snapshot, context) {
    const message: FirebaseFirestore.DocumentData = snapshot.data();
    const folderPath: string = `chats/${message.chatid}/messages/${message.id}/`;
    const bucket = admin.storage().bucket();
    try {
        await bucket.deleteFiles({
            prefix: folderPath
        });
    } catch (err) {
        console.log(`Error when deleting files of message ${message.chatid}, ${message.text} :`, err);
    }
});
