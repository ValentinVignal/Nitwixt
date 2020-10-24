export default interface UserPushTokens {
    id: 'pushTokens',
    userId: string,
    username: string,
    tokens?: string[],
};