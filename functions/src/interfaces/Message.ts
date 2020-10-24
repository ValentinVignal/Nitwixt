export default interface Message {
    id: string,
    date: FirebaseFirestore.Timestamp,
    text: string,
    userid: string,
    previousMessageId?: string,
    chatid: string,
    images?: string[],
    reacts?: Object,
};