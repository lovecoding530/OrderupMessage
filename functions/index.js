const functions = require('firebase-functions');

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });

const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);


/*
 * 'OnWrite' works as 'addValueEventListener' for android. It will fire the function
 * everytime there is some item added, removed or changed from the provided 'database.ref'
 * 'sendNotification' is the name of the function, which can be changed according to
 * your requirement
 */

exports.sendOrderupNotificationCreate = functions.database.ref('/restaurants/{res_id}/messages/{user_id}/{sender_id}').onCreate(event => {
    const res_id = event.params.res_id;
    const user_id = event.params.user_id;
    const sender_id = event.params.sender_id;

    console.log("created update", user_id);

    if(!event.data.val()){
    	console.log('A Notification has been deleted from the database : ', user_id);
    }

    return sendMessage(res_id, user_id, sender_id);
});

exports.sendOrderupNotificationUpdate = functions.database.ref('/restaurants/{res_id}/messages/{user_id}/{sender_id}').onUpdate(event => {
    const res_id = event.params.res_id;
    const user_id = event.params.user_id;
    const sender_id = event.params.sender_id;

    console.log("created update", user_id);

    if(!event.data.val()){
    	console.log('A Notification has been deleted from the database : ', user_id, sender_id);
    }

    return sendMessage(res_id, user_id, sender_id);
});

function sendMessage(res_id, user_id, sender_id){

    console.log('notification order start');

    console.log("user_id: ", user_id);
    console.log("sender_id: ", sender_id);

	return admin.database().ref(`/restaurants/${res_id}/users/${user_id}`).once('value', (snapshot) => {
		var   user = snapshot.val();
		const token_id = user.fcm_token;

		console.log("user: ", user);

		return admin.database().ref(`/restaurants/${res_id}/messages/${user_id}/${sender_id}`).once('value', (snapshot) => {
			var   message = snapshot.val();
			const sender_name = message.sender_name;
			const message_str = message.message;
			console.log("user: ", user);

		    const payload = {
			    notification: {
			      title: "From " + sender_name,
			      body:  message_str,
			      sound: "default",
			      badge: "0"
			    },
			    data: {
			    	sender_id: sender_id
			    }
		    };
			
		    return admin.messaging().sendToDevice(token_id, payload).then(response => {

		    	console.log('This was the notification Feature');

			});
		});
	});
}