

export function nameToDisplay(chat: any, user: any, sender: any) {
    if(chat.name) {
        return chat.name;
    } else {
        if (chat.members.lenght === 1) {
            return `{user.name} (You)`;
        } else if (chat.members.lenght === 2) {
            // Private chat
            return sender.name;
        } else {
            // Group chat
            return 'Group Chat'
        }
    }
}