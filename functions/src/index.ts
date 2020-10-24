import * as admin from 'firebase-admin';
try {admin.initializeApp();} catch(e) {} // You do that because the admin SDK can only be initialized once.

import { _onDeleteChat } from './functions/chat/onDeleteChat';
import { _onNewMessage } from './functions/message/onNewMessage';
import { _onDeleteMessage } from './functions/message/onDeleteMessage';
import { _createChat } from './functions/chat/createChat';
import { _updateChat } from './functions/chat/updateChat';
import { _migratePushTokensToPublic } from './migrations/migratePushTokensToPublic';




// // Start writing Firebase Functions
// // https://firebase.google.com/docs/functions/typescript
//
// export const helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });



// * ------------------------------ Chats ------------------------------

export const createChat = _createChat;

export const onDeleteChat = _onDeleteChat;

export const updateChat = _updateChat;

// * ------------------------------ Messages ------------------------------

export const onNewMessage = _onNewMessage;

export const onDeleteMessage = _onDeleteMessage;

// ----------------------------------------------------------------------------------------------------

export const migratePushTokensToPublic = _migratePushTokensToPublic;

