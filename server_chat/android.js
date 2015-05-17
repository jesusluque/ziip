
var GCM = require('./gcm');
 
var gcm = new GCM("AIzaSyCuGaCj0ZTWqgkBcSChqQ2AYcVEboaQWDQ"); // https://code.google.com/apis/console
 

var msg = {
  registration_ids: ["APA91bExX-rlqhOjK76N3SDAYWE3toGCwBywi2GP4WFWjW-8rR-4V_XIr-3yZWUTYF1sYW1yTotLwG5dVqS1FKMIKvWrI6VwIIDBZJiLQb2jdFkjqN6EXdA4CriCMoCrfhpsJusF5pOI"], // this is the device token (phone)
  collapse_key: "newWallEntry", // http://developer.android.com/guide/google/gcm/gcm.html#send-msg
  time_to_live: 180, // just 30 minutes
  data: {
    message: "Hola Carlos!", 
	action: "newWallEntry",
	name :"Manu",
	id: "123",
  }
};
 


// send the message and see what happened
gcm.send(msg, function(err, response) {
 
  console.log(response); // http://developer.android.com/guide/google/gcm/gcm.html#response
});
