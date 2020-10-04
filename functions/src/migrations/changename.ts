import * as functions from 'firebase-functions';
import admin from '../admin';

export const changename = functions.https.onRequest(async function (request, response) {
    const bucket = admin.storage().bucket();
    let files = (await bucket.getFiles())[0];
    files = files.filter(function(file) {
        return file.name.endsWith('profilePicture.jpg');
    });
    const listPromise: Promise<any>[] = [];
    files.forEach(async function(file) {
        const newName = file.name.split('/').slice(0, -1).join('/') + '/picture';
        listPromise.push(file.move(newName));
    });
    await Promise.all(listPromise);

    const allNames: string[] = [];
    files.forEach(function(file) {
        allNames.push(file.name);
    });
    response.send("Done\n\n" + allNames.join('\n'));
});
