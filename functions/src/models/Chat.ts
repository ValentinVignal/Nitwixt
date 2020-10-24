import * as interfaces from '../interfaces';

export  default class Chat {
    id: interfaces.Chat['id'];
    name: interfaces.Chat['name'];
    members: interfaces.Chat['members'];

    constructor(chatInterface: interfaces.Chat) {
        this.id = chatInterface.id;
        this.name = chatInterface.name;
        this.members = chatInterface.members;
    }

    get interface(): interfaces.Chat {
        return {
            id: this.id,
            name: this.name,
            members: this.members
        };
    }

    displayName(sender: interfaces.User): string {
        if(this.name) {
            return this.name;
        }
        if (this.members.length === 1) {
            return '(@You)';
        } else if (this.members.length === 2) {
            return sender.name || sender.username;
        } else {
            return 'Group Chat';
        }
    }

    static get collection(): string {
        return 'chats';
    }
};
