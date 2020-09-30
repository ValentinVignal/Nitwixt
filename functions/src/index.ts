import * as admin from 'firebase-admin';

import { _deleteChat } from './functions/chat/deleteChat';
import { _newMessage } from './functions/message/newMessage';
import { _deleteMessage } from './functions/message/deleteMessage';

import { _migrateChatsToPrivate } from './migrations/migrateChatsToPrivate';

admin.initializeApp();

// // Start writing Firebase Functions
// // https://firebase.google.com/docs/functions/typescript
//
// export const helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });



// * ------------------------------ Chats ------------------------------

export const deleteChat = _deleteChat;

// * ------------------------------ Messages ------------------------------

export const newMessage = _newMessage;

export const deleteMessage = _deleteMessage;

// ----------------------------------------------------------------------------------------------------

export const migrateChatsToPrivate = _migrateChatsToPrivate;

