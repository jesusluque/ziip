
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

user_id="1" //user id  
text="texto"
message={
    "serverId": "data.serverId",
    "text": "data.text",
    "from": "data.from",
    "type": "data.type",
    "date": "data.date",
    "readed": "data.readed",
    "destination": "data.destination"
}

sendNotification(connection,user_id,text,message);

