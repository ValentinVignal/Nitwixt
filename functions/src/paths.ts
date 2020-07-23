/**
 * @function
 * @name deleteFolder
 * @description Delete all the files recursively in a folder in Firebase Storage
 * 
 * @param path: The path of the folder
 * @param storage
 */
export async function deleteFolder(bucket: any, path: string) {
    const files: File[] = (await bucket.getFiles({directory: path}))[0];
    bucket.file 
    const deletions: Promise<any>[] = [];
    files.forEach(function(file: File) {
        deletions.push(bucket.file(file.name).delete().catch(function(err: any) {
            console.log(`Error when deleting a file ${file.name} :`, err);
        }));
    });
    await Promise.all(deletions);
}