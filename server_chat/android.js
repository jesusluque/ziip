
var GCM = require('./gcm');

var gcm = new GCM("AIzaSyCwgZeTLnOgx3IwHFfuRaLAuZsl-BnnGes");


var msg = {
  registration_ids: ["dUFKVW2q4xM:APA91bGLQiNfTEiYsA1sN3lnu6cR9C-1ytLSlqSwZ_7n1YlA_IpKZeZP9YGu5EmRDbQhs5A8c_zcAUt8V-Y4IlIFpJLyViJ0DNI3_lObhucv4krkeKbRgdhqBF1dqCdRSAhmoruIzTra"],
  collapse_key: "newChat",
  time_to_live: 180,
  data: {
      "readed":0,
      "text":"test1",
      "from":"272",
      "serverId":582,
      "date":"2015-11-24 19:08:14 GMT+02:00",
      "type":"1",
      "destination":"272"
  }

};




// send the message and see what happened
gcm.send(msg, function(err, response) {

  console.log(response); // http://developer.android.com/guide/google/gcm/gcm.html#response
});
