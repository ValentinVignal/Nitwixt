import * as functions from 'firebase-functions';

const updateTypes = {
    members: 'members'
};

export const _updateChat = functions.https.onCall(async function(data, context) {
    try {
        switch (data.updateType) {
            case (updateTypes.members) {
                return await updateMembers(data);
            }
        }
    } catch (error) {
        return {
            error: error.toString()
        };
    }
});

async function updateMembers(data: any) : Object {
    // hello im here to interrupt valentin's app code :p if you delete it you will have a bad luck
}