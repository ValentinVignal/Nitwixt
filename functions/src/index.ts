import * as admin from 'firebase-admin';

import { _onDeleteChat } from './functions/chat/deleteChat';
import { _onNewMessage } from './functions/message/newMessage';
import { _onDeleteMessage } from './functions/message/deleteMessage';

import { _migrateChatsToPrivate } from './migrations/migrateChatsToPrivate';
import { _createChat } from './functions/chat/createChat';

admin.initializeApp();

// // Start writing Firebase Functions
// // https://firebase.google.com/docs/functions/typescript
//
// export const helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });



// * ------------------------------ Chats ------------------------------

export const createChat = _createChat;

export const onDeleteChat = _onDeleteChat;

// * ------------------------------ Messages ------------------------------

export const onNewMessage = _onNewMessage;

export const onDeleteMessage = _onDeleteMessage;

// ----------------------------------------------------------------------------------------------------

export const migrateChatsToPrivate = _migrateChatsToPrivate;

