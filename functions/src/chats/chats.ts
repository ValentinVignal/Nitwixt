import admin from '../admin';

export const chatsCollection = admin.firestore().collection('chats');

/**
 * @function
 * @name nameToDisplay
 * @description Returns the name of the chat for a specific user
 * 
 * @param chat 
 * @param user 
 * @param sender 
 * 
 * @returns {string}
 */
export function nameToDisplay(chat: any, user: any, sender: any) {
    if(chat.name) {
        return chat.name;
    } else {
        if (chat.members.length === 1) {
            return `(@You)`;
        } else if (chat.members.length === 2) {
            // Private chat
            return sender.name;
        } else {
            // Group chat
            return 'Group Chat';
        }
    }
}