import Chat from "./chat";
import User from "./User";

export default interface UserPublicChats { 
    chats?: Chat['id'][]
    id: 'chats',
    userId: User['id'],
    username: User['username']
}