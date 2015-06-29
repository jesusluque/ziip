
var conf      = require('./config');

//Conectamos al mysql
var mysql      = require('mysql');
var connection = mysql.createConnection({
  host     : conf.mysqlHost,
  user     : conf.mysqlUser,
  password : conf.mysqlPass,
  database : conf.mysqlDatabase,
});

var notify = require('./notify');

connection.connect();

user_id="9" //user id  
text="Hola Jesus, te llega la notif push??"
message={
    "serverId": "data.serverId",
    "text": "data.text",
    "from": "data.from",
    "type": "data.type",
    "date": "data.date",
    "readed": "data.readed",
    "destination": "data.destination"
}

setTimeout(function() {
  sendNotification(connection,user_id,text,message);
}, 5000);


