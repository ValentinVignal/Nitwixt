

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