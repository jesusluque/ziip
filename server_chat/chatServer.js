// Author: Manuel Rodriguez Morales
// Email: marodriguez@marodriguez.com

//Basado en el proyecto:
// Url GitHub:https://github.com/tegioz/chat 
// Author: Sergio Castaño Arteaga
// Email: sergio.castano.arteaga@gmail.com

// ***************************************************************************
// General
// ***************************************************************************


var conf      = require('./config');

//Conectamos al mysql
var mysql      = require('mysql');
var connection = mysql.createConnection({
  host     : conf.mysqlHost,
  user     : conf.mysqlUser,
  password : conf.mysqlPass,
  database : conf.mysqlDatabase,
});

fs = require('fs');

//definimos el agente para las notificaciones push
var notify = require('./notify');



function handleDisconnect(connection) {
  connection.on('error', function(err) {
	  
    logger.emit('newEvent', 'Error de conexion mysql', err);
    if (!err.fatal) {
      return;
    }

    /*if (err.code !== 'PROTOCOL_CONNECTION_LOST') {
      throw err;
    }*/

    console.log('Re-connecting lost connection: ' + err.stack);
    connection = mysql.createConnection({
        host     : conf.mysqlHost,
        user     : conf.mysqlUser,
        password : conf.mysqlPass,
        database : conf.mysqlDatabase,
    });
    handleDisconnect(connection);
    logger.emit('newEvent', 'Reconectamos', err);
    connection.connect();
  });
}
handleDisconnect(connection);
connection.connect();

function checkConnection(){

console.log("Checkeamos la conexion con estado "+connection.state);

    if (connection.state=="disconnected") {
console.log ("esta desconectado, reconectamos");
        connection = mysql.createConnection({
            host     : conf.mysqlHost,
            user     : conf.mysqlUser,
            password : conf.mysqlPass,
            database : conf.mysqlDatabase,
        });
        handleDisconnect(connection);
        connection.connect();
    }

}


//Vamos a empezar a cargar los datos de inicio del server.

//Primero nos traemos el id de img para las imagenes que envian los usuarios
/*
var id_img=1;
connection.query('SELECT sequence from chat_config', function(err, rows) {
	if (err) return logger.emit('newEvent', 'error al leer secuencia imgs', err);
	if (rows.length>0){
		id_img=rows[0].sequence
	} else {
		connection.query('insert into chat_config values(1)', function(err, result) {
			if (err) return logger.emit('newEvent', 'error al guardar secuencia de img', err);
		});
	}
});
*/

var bloqueos={};

connection.query('SELECT * from core_chatbloqueos ', function(err, rows) {
	if (err) return logger.emit('newEvent', 'error al leer los bloqueos', err);
	for (i in rows) {
		var row=rows[i];
		var bloq_user = [];
		if (bloqueos[row.usuario]) {
			bloq_user = bloqueos[row.usuario];
		} else {
			bloq_user = [];
		}
		bloq_user.push(row.bloqueado);
		bloqueos[row.usuario]= bloq_user;
	}
});


//Funcion para parsear la fecha
var time = require('time');
var formatDate = function(fecha) {
	
	
	console.log("la fecha que formateamos es"+fecha)
	var mes=fecha.getMonth()+1;
	var dia=fecha.getDate();
	if (mes<10){
		mes="0"+mes;
	}
	if (dia<10){
		dia="0"+dia;
	}
	return fecha.getFullYear()+"-"+mes+"-"+dia+" "+fecha.toLocaleTimeString();
	
};
var formatFechaBBDD = function (fecha) {
	//2013-06-19T14:56:50.000Z
	fecha=fecha.str_replace("T"," ").str_replace(".000Z"," GMT+02:00")
	return fecha;
};


// External dependencies
var express = require('express'),
    http = require('http'),
    socketio = require('socket.io'),
    events = require('events'),
    _ = require('underscore'),
    redis = require('redis'),
    sanitize = require('validator').sanitize;

// HTTP Server configuration & launch
var app = express(),
    server = http.createServer(app),
    io = socketio.listen(server);
server.listen(conf.port);

// Express app configuration
app.configure(function() {
    app.use(express.bodyParser());
    app.use(express.static(__dirname + '/static'));
});

// Socket.io store configuration
var RedisStore = require('socket.io/lib/stores/redis'),
    pub = redis.createClient(conf.dbPort, conf.dbHost, conf.dbOptions),
    sub = redis.createClient(conf.dbPort, conf.dbHost, conf.dbOptions),
    db = redis.createClient(conf.dbPort, conf.dbHost, conf.dbOptions);
	
io.set('store', new RedisStore({
    redisPub: pub,
    redisSub: sub,
    redisClient: db
}));
io.set('log level', 1);

// Logger configuration
var logger = new events.EventEmitter();
logger.on('newEvent', function(event, data) {
    console.log('%s: %s', event, JSON.stringify(data));
});


// ***************************************************************************
// Socket.io events
// ***************************************************************************

io.sockets.on('connection', function(socket) {

    // Welcome message on connection
    var address = socket.handshake.address;
    console.log("usuario conectado:"+address.address);
    
    // Store user data in db
    db.hset([socket.id, 'connectionDate', new Date()], redis.print);
    db.hset([socket.id, 'socketID', socket.id], redis.print);
    db.hset([socket.id, 'username', 'anonymous'], redis.print);


    socket.on('login', function(data) {
        logger.emit('newEvent', 'El estado de la conexion es ', connection.state);
        checkConnection();
		
        logger.emit('newEvent', 'Recibimos una peticion de login2', data);
        if (data.pass !="" && data.user !="" ){
            var sql = 'SELECT * from core_usuarios where usuario="'+data.user+'" and password="'+data.pass+'"';
            logger.emit('newEvent', sql,{});
            connection.query(sql, function(err, rows) {
                if (err) return logger.emit('newEvent', 'error1', err);
                logger.emit('newEvent', 'El query del login es correcto', err);
                if (rows.length>0){
                    db.hset([socket.id, 'userId', rows[0].id], redis.print);
                    db.hset([socket.id, 'userName', rows[0].name+" "+rows[0].last_name], redis.print);
                    if (data.device) {
                         device="browser";
                    } else { 
                        device="movil";
		            }	
                    db.hset([socket.id, 'device', device], redis.print);
                    //db.hset([rows[0].id, 'socketId', socket.id], redis.print);
                    socket.join(rows[0].id);
                    var message={
                        "status":"ok","userId":rows[0].id
                    };
                } else {
                    logger.emit('newEvent', 'No hay row', err);
                    /*message={
                        "status":"error"
                    };*/
                    socket.disconnect();
                }	
                socket.emit('login', message);
                
            });
        } else {
            socket.disconnect();
        }
    });
	
    socket.on('newMsg', function(data) {

        logger.emit('newEvent', 'Recibimos new Msg',data);

        db.hgetall(socket.id, function(err, objOrigen) {
            if (err) return logger.emit('newEvent', 'error2', err);
			
				var userId=objOrigen.userId;
				if (userId) {
					//Esta logado, guardamos el mensaje en la bbdd
					var fecha=new time.Date();	
					fecha.setTimezone('Europe/Madrid');
					console.log("pedimos format1 date1 de fecha "+fecha)
					var str_fecha=formatDate(fecha);
					logger.emit('newEvent', 'mensaje para el usuario '+data.to, null);
                    /*
					if (data.type==2) {
						var this_img=++id_img;
						connection.query('update chat_config set sequence='+this_img, function(err, result) {
							if (err) return logger.emit('newEvent', 'error al actualizar secuencia de img', err);
						});
						var imgData=new Buffer(data.text, 'base64'); 
						fs.writeFile(conf.imgFullPath+'image_'+this_img+'.png', imgData, function (err) {
						    if (err) throw err;
						                    console.log('It\'s saved!');
						});
						data.text=conf.imgPublicPath+'image_'+this_img+'.png';	
					}
                    */
                    
                    if (data.type==4 || data.type==5){
                        //Bloqueamos o desbloqueamos
                		var bloq_user = [];
                		if (bloqueos[userId]) {
                			bloq_user = bloqueos[userId];
                		} else {
                			bloq_user = [];
                		}
                        var sql
                        if (data.type=="4") {
                            console.log("bloqueamos");
                			bloq_user.push(data.bloqueado_id);
                            sql='insert core_bloqueoschat (usuario,bloqueado) values ("'+userId+'","'+data.to+'")';
                    
                		} else {
                             console.log("desbloqueamos");
                			if (bloq_user.indexOf(data.destination)>=0) {
                				bloq_user.splice(bloq_user.indexOf(data.to),1);
                			}
                            sql='delete * from core_bloqueoschat where usuario="'+userId+'" and bloqueado="'+data.to+'" ';
                    
                		}
                		bloqueos[userId]= bloq_user;
        				connection.query(sql, function(err, result) {
        					if (err) return logger.emit('newEvent', 'error en bloquear usuario', {'sql':sql, 'error':err});
                        });
                    }
                    
					//comprobamos si esta bloqueado
					var blocked = "0";
				
					if (bloqueos[data.to]) {
						var bloqueos_del_user = bloqueos[data.to];
						if (bloqueos_del_user.indexOf(userId)>=0) {
							blocked="1";
						}
					}
					
					connection.query('insert into core_chatmensajes (texto,fecha,recibido,usuario,destinatario,tipo, bloqueado) values ("'+data.text+'","'+data.date+'","'+str_fecha+'","'+userId+'","'+data.to+'","'+data.type+'","'+blocked+'")', function(err, result) {
						//Le indicamos que lo hemos recibido
						if (err) return logger.emit('newEvent', 'error3', err);
						str_fecha=str_fecha+" GMT+02:00"
						var message={
							"id":data.id,
							"serverId":result.insertId,
							"serverDate":str_fecha,
						}
						socket.emit('recMsg',message);
						if (blocked=="0") {
							//y se lo enviamos al otro usuario
						
							
							var message = {
								"serverId":result.insertId,
								"text":data.text,
								"from":userId+"",
                                "destination":data.to+"",
								"type":data.type+"",
								"date":str_fecha, 
                                "readed":0,
							}
							//Enviamos anuestro otro dispositivo
							
                            var socketsInRoom = io.sockets.clients(userId);
							if (socketsInRoom.length != 0) {
                                for (sock in socketsInRoom) {
                                    var other_socket = socketsInRoom[sock]
                                    if (other_socket.id != socket.id){ 
                                        console.log("Enviamos al socket:"+other_socket.id);
                                        other_socket.emit('newMsg',message);
                                    }
                                }
                            } 
							//Enviamos al amigo
                            var socketsInRoom = io.sockets.clients(data.to);
                            console.log("Cantidad de sockets:"+socketsInRoom.lenght)
                            enviarMovil = true;
		                    if (socketsInRoom.length==0) {
                                 var userName = objOrigen.userName;
                                 var text = userName+": "+data.text;
                                 sendNotification(connection,data.to,text,message);
                                 //Tenemos desactivadas las notificaciones push
                            } else {
                                var roomsDone=0;
                                for (sock in socketsInRoom) {
                                    db.hget(socketsInRoom[sock].id, "device", function(err, value) { 
                                        roomsDone++;

                                        console.log("En el hget");
                                        console.log(value);
                                        if (value=="movil") {

                                            enviarMovil=false;
                                        }
                                        console.log("socket.len",socketsInRoom.length);
                                        console.log("rooomsdone",roomsDone);
                                        if (roomsDone===socketsInRoom.length){
                                            if (enviarMovil) {
                                                logger.emit('newEvent', 'el destino no esta conectado, notificamos por PUSH',null);
                                                var userName = objOrigen.userName;
                                                var text = userName+": "+data.text;
                                                sendNotification(connection,data.to,text,message);
                                            }
                                        }
                                    });
                                    console.log("Le enviamos el mensaje al socket:"+socketsInRoom[sock].id)
                                    socketsInRoom[sock].emit('newMsg',message);
                                }
                            } 
                        }
					});
				} else {
                     logger.emit('newEvent', 'No tenemos userId en el redis',null);
                }
        });
    });
    
	
	socket.on('recMsg', function(data) {
        db.hgetall(socket.id, function(err, objOrigen) {
            if (err) return logger.emit('newEvent', 'error4', err);
				var userId = objOrigen.userId;
				if (userId) {
					var fecha=new time.Date();	
					fecha.setTimezone('Europe/Amsterdam');
					console.log("pedimos format date2 de fecha "+fecha)
					var str_fecha=formatDate(fecha);
					var sql='update core_chatmensajes set enviado ="'+str_fecha+'" where id='+data.serverId;
					connection.query(sql, function(err, result) {
						if (err) return logger.emit('newEvent', 'error5', {'sql':sql, 'error':err});
						sql='select usuario  from core_chatmensajes where id="'+data.serverId+'"';
						connection.query(sql, function(err, rows) {
							if (err) return logger.emit('newEvent', 'error6', {'sql':sql, 'error':err});
							if (rows.length>0){
								
								var socketsInRoom = io.sockets.clients(rows[0].user);
								if (socketsInRoom.length>0){
									var message = {
										"serverId":data.serverId,
									}
                                    for (sock in socketsInRoom) {
                                        socketsInRoom[sock].emit('readMsg',message);
                                    }

								} else{
									logger.emit('newEvent', 'Como el destino no esta conectado no le notificamos que el otro usuario ha leido el mensaje',null);
								}
							}
						});
					});
					
				}
			});
	
	});
	socket.on('readMsg', function(data) {
		console.log("recibo read msg con mensaje"+data.serverId );
        db.hgetall(socket.id, function(err, objOrigen) {
            if (err) return logger.emit('newEvent', 'error11', err);
				var userId=objOrigen.userId;
				if (userId) {
					var fecha=new time.Date();	
					fecha.setTimezone('Europe/Amsterdam');
					console.log("pedimos format date3 de fecha "+fecha)
					var str_fecha=formatDate(fecha);
					var sql='update core_chatmensajes set leido="'+str_fecha+'" where id='+data.serverId;
					connection.query(sql, function(err, result) {
						if (err) return logger.emit('newEvent', 'error12', {'sql':sql, 'error':err});
					});
				}
			});
	});
    
	socket.on('getUserInfo', function(data) {
		console.log("getUserInfo"+data.id );
        db.hgetall(socket.id, function(err, objOrigen) {
            if (err) return logger.emit('newEvent', 'error11', err);
				var userId=objOrigen.userId;
				if (userId) {
					var sql='select * from core_usuarios where id="'+data.id+'"';
                    logger.emit('newEvent', sql, {});
					connection.query(sql, function(err, result) {
						if (err) return logger.emit('newEvent', 'error en get user info', {'sql':sql, 'error':err});
                        logger.emit('newEvent', 'lo obtneido en get user info', result);
                        var row=result[0];
                        logger.emit('newEvent', 'lo obtneido en get user info', row);
                        var imagen;
                        if (row.imagen == null ) {
                            imagen="2";
                        } else {
                            imagen= row.imagen;
                        }
    					var datos = {
    						"id":row.id,
    						"usuario":row.usuario,
                            "imagen":imagen
    					}
    					socket.emit('getUserInfo',datos)        
					});
                    
                    
				}
			});
	});
    
    
    
	/*
	socket.on('getOldMsg', function(data) {
		//Obtenemos los mensajes antiguos de un usuario, dado un id.
        db.hgetall(socket.id, function(err, objOrigen) {
            if (err) return logger.emit('newEvent', 'error8', err);
			var userId=objOrigen.userId;
			// Todo desde el ultimo mensaje
			//var sql="select * from app_messenger where (user='"+userId+"' or destination='"+userId+"') and id>'"+data.lastMsg+"'";
			
			//solo se envian los no leidos con destino al usuario conectado.
			var sql="select * from core_chat_mensajes where  destinatario='"+userId+"' and enviado is null and block='0'";
			logger.emit('newEvent', "getOldMsg query", sql);
			connection.query(sql, function(err, result) {
				if (err) return logger.emit('newEvent', 'error9', sql);
				var newMsgs=new Array();
				for (i in result) {
					var row=result[i];
					console.log("pedimos format1 date4 de fecha "+row.date)
                    
					var message = {
						"serverId":row.id,
						"text":row.name,
						"from":row.user+"",
						"destination":row.destination,
						"type":row.type+"",
						"date":formatDate(row.date)+" GMT+02:00",
					}
					logger.emit('newEvent', 'el message que hacemos push es:', message);
					newMsgs.push(message);	
				}
			    //Ya tenemos los mensajes que no hemos enviado.
				
				var sql="select * from app_messenger where  user='"+userId+"' and readed is null and block='0' and sended is not null";
				logger.emit('newEvent', "getOldMsg, readMsg query", sql);
				connection.query(sql, function(err, result) {
					if (err) return logger.emit('newEvent', 'error10', sql);
					var readMsgs=new Array();
					for (i in result) {
						var row=result[i];
						var message = {
							"serverId":row.id,	
						}
						readMsgs.push(message);	
					}
					
					var datos = {
						"readMsg":readMsgs,
						"newMsg":newMsgs,
					}
			
					socket.emit('getOldMsg',datos)
		
				});
			});	
		});	
	});
    */
	socket.on('getOldMsg2', function(data) {

		//Obtenemos los mensajes antiguos de un usuario, dado un id.
        db.hgetall(socket.id, function(err, objOrigen) {
            if (err) return logger.emit('newEvent', 'error8', err);
			var userId=objOrigen.userId;
			// Todo desde el ultimo mensaje
			var sql="select * from core_chatmensajes where (usuario='"+userId+"' or destinatario='"+userId+"') and id>'"+data.lastMsg+"' and bloqueado='0' order by id  asc";
            console.log(sql);
			connection.query(sql, function(err, result) {
				if (err) return logger.emit('newEvent', 'error9:'+sql, err);
				var newMsgs=new Array();
				for (i in result) {
					var row=result[i];
                    var readed=1;
                    if (row.readed==null) {
                        readed=0;
                    } 
					var message = {
						"serverId":row.id,
						"text":row.texto,
						"from":row.usuario+"",
						"destination":row.destinatario,
						"type":row.tipo+"",
						"date":formatDate(row.fecha)+" GMT+02:00",
                        "readed":readed,
					}
					newMsgs.push(message);	
				}
			    //Ya tenemos los mensajes que no hemos enviado.
				
				var sql="select * from core_chatmensajes where  usuario='"+userId+"' and leido is null and bloqueado='0' and enviado is not null";
				connection.query(sql, function(err, result) {
					if (err) return logger.emit('newEvent', 'error10:'+sql, err);
					var readMsgs=new Array();
					for (i in result) {
						var row=result[i];
						var message = {
							"serverId":row.id,	
						}
						readMsgs.push(message);	
					}
					
					var datos = {
						"readMsg":readMsgs,
						"newMsg":newMsgs,
					}
			
					socket.emit('getOldMsg',datos)
		
				});
			});	
		});	
	});
    
    
  /*
 	socket.on('blockFriend', function(data) {


        db.hgetall(socket.id, function(err, objOrigen) {
            if (err) return logger.emit('newEvent', 'error11', err);
			var userId=objOrigen.userId;
			if (userId) {
        		var bloq_user = [];
        		if (bloqueos[userId]) {
        			bloq_user = bloqueos[userId];
        		} else {
        			bloq_user = [];
        		}
                var sql
        		if (data.block=="1") {
                    console.log("bloqueamos");
        			bloq_user.push(data.bloqueado_id);
                    sql='insert core_bloqueoschat (usuario,bloqueado) values ("'+userId+'","'+data.bloqueado_id+'")';
                    
        		} else {
                     console.log("desbloqueamos");
        			if (bloq_user.indexOf(data.destination)>=0) {
        				bloq_user.splice(bloq_user.indexOf(data.bloqueado_id),1);
        			}
                    sql='delete * from core_bloqueoschat where usuario="'+userId+'"';
                    
        		}
        		bloqueos[userId]= bloq_user;
				connection.query(sql, function(err, result) {
					if (err) return logger.emit('newEvent', 'error en bloquear usuario', {'sql':sql, 'error':err});
                });
                
                    
            }
        });
    });      
    
    */  
 	// Clean up on disconnect
    socket.on('disconnect', function() {
    
        // Get current rooms of user
        var rooms = _.clone(io.sockets.manager.roomClients[socket.id]);
        
        // Get user info from db
        db.hgetall(socket.id, function(err, obj) {
            if (err) return logger.emit('newEvent', 'error7', err);
                logger.emit('newEvent', 'userDisconnected', {'socket':socket.id, 'username':obj.username});
                // Notify all users who belong to the same rooms that this one
                db.del(socket.userId,redis.print);
        });
        // Delete user from db
        db.del(socket.id, redis.print);
    });
});

/*
//Gestion de errores
var logStream = fs.createWriteStream(conf.errorLog, {flags:'a'});
process.on('uncaughtException', function (err) {

	    logStream.write("\nError: "+err.message);
	    logStream.write(err.stack);
});

*/
