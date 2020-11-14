export default interface Chat {
    id: string,
    name?: string,
    members: string[],
    date?: FirebaseFirestore.Timestamp,
}