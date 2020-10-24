// import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
try {admin.initializeApp();} catch(e) {} // You do that because the admin SDK can only be initialized once.

import * as interfaces from '../interfaces';


export const usersCollection = admin.firestore().collection('users');


export async function userList(usernames: string[]): Promise<interfaces.User[]> {
    return await usersFromField(usernames);
}

/**
 * 
 * @param values 
 * @param [fieldName]
 */
export async function usersFromField(values: string[], fieldName: string = 'username') : Promise<interfaces.User[]> {
    // Check inputs
    if (!fieldName || !values.length)  {
        return Promise.reject('fieldName and values can\'t be empty');
    }
    // Get the documents of the users
    const querySnapshots = await Promise.all(values.map(async function(value) {
        return await admin.firestore().collection('users').where('username', '==', value).get();
        // return await usersCollection.where(fieldName, '==', value).get();
    }));
    // check all the users have been found
    const unknownUsers: string[] = [];
    querySnapshots.forEach(function(querySnapshot, index) {
        if (querySnapshot.empty) {
            unknownUsers.push(values[index]);
        }
    });
    if (unknownUsers.length) {
        return Promise.reject(`Users with ${fieldName} ${unknownUsers.join(', ')} don't exist`);
    }
    return querySnapshots.map<interfaces.User> (function(document) {
        return document.docs[0].data() as interfaces.User;
    });
}