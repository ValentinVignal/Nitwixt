import * as functions from 'firebase-functions';
import  admin from '../../admin';

/**
 * This function deletes all the messages on the deletion of a chat
 */
export const _onDeleteChat = functions.firestore.document('chats/{chatId}').onDelete(async function (snapshot, context) {
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
});