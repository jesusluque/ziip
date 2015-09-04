


var socket;
var nNews = 0;
var ID = 0;
var users = new Array();
var templates = {};
var autoId = 1;

/*
var chatSound = new buzz.sound("sounds/buip", {
	formats: ["ogg", "mp3", "acc"]
});
*/

function loginChat(user, password) {


	if (typeof socket == 'undefined') {

        //comentado por manu
		//changeChatStatus('Connecting...');
		socket = io.connect('http://213.251.185.53:8888');

		// Connection established
		socket.on('connect', function(data) {
			// Hacer login
			var login = {
				user : user,
				pass : password,
			 	//chatToken: password,
				device: 'browser'
			};
			console.log(' > login:');
			console.log(login);
			socket.emit('login', login);
		});

		// Login
		socket.on('login', function(data) {
			console.log(' < login:');
			console.log(data);
			if (data.status == 'ok') {
                ID = data.userId;
				//comentado por manu
				//changeChatStatus('Connected');

				//comentado por manu
				//getNewMessages();
				imagen="";
				initChat(socket, ID,imagen);
			} else {
				//comentado por manu
                //changeChatStatus('Disconnected');
			}
		});


        //REVISADO HASTA AQUI!!!

		// Nuevo mensaje
		socket.on('newMsg', function(data) {
			console.log(' < newMsg:');
			console.log(data);

			// Avisar al iframe
			onNewMsg(data);
		});

		// Recibido en el servidor
		socket.on('recMsg', function(data) {
			console.log(' < recMsg:');
			console.log(data);

			// Avisar al iframe
			onRecMsg(data);
		});

		// Mensaje leido por el destinatario
		socket.on('readMsg', function(data) {
			console.log(' < readMsg:');
			console.log(data);

			console.log(' > readMsg:');
			console.log(data);
			socket.emit('readMsg', data);

			// Avisar al iframe
			onReadMsg(data);
		});

		// Desconectado
		socket.on('disconnect', function(data) {
			console.log(' < disconnect:');
			changeChatStatus('Disconnected');
		});

		// Reconnected to server
		socket.on('reconnect', function(data) {
			console.log(' < reconnect:');
			changeChatStatus('Reconnecting...');
		});

	} else {
		if (socket.socket.connected) {
			changeChatStatus('Connected');
			setNewMessages();
			initChat(socket, ID, image);
		}
	}
}

function logoutChat(){
	if (typeof socket != 'undefined') {
		socket.disconnect();
		window.location.reload();
	}
	socket = undefined;
}


/*
Comentado por manu
function getNewMessages() {
	$.ajax({
		url : 'ajax.php',
		dataType : 'json',
		data : {
			action : 'getNumNewMessages'
		},
		success : function(data) {
			nNews = data.nMessages;
			setNewMessages();
		}
	});
}
*/

function setNewMessages() {
	if (iframeCW != null && iframeCW.setNewMessages != null) {
		iframeCW.setNewMessages(nNews);
	}
}

function increaseNewMessages(increase, notify) {
	nNews += increase;
	setNewMessages();
	if (notify) {
		chatSound.play();
		titleAlert('New Chat Message');
	}

}

function decreaseNewMessages(decrease) {
	nNews -= decrease;
	if (iframeCW != null && iframeCW.setNewMessages != null) {
		iframeCW.setNewMessages(nNews);
	}
}

function resetNewMessages() {
	nNews = 0;
	if (iframeCW != null && iframeCW.setNewMessages != null) {
		iframeCW.setNewMessages(nNews);
	}
}

function changeChatStatus(status) {
	if (iframeCW != null && iframeCW.changeChatStatus != null) {
		iframeCW.changeChatStatus(status);
	}
}

function titleAlert() {
	$.titleAlert("New Chat message!", {
		stopOnFocus : true
	});

	if (iframeCW != null && iframeCW.bindMouseMove != null) {
		iframeCW.bindMouseMove();
	}
}

function titleStop() {
	$.titleAlert.stop();
}
/*
Comentado por manu
function initChat(socket, id, image) {
	if (iframeCW != null && iframeCW.initChat != null) {
		iframeCW.initChat(socket, id, image);
	}
}*/

function onNewMsg(data) {
	if (iframeCW != null && iframeCW.onNewMsg != null) {
		iframeCW.onNewMsg(data);
	} else {
		// Incrementar el nNews
		if (data.from != ID) {
			increaseNewMessages(1, true);
		}
	}
}

function onRecMsg(data) {
	if (iframeCW != null && iframeCW.onRecMsg != null) {
		iframeCW.onRecMsg(data);
	}
}

function onReadMsg(data) {
	if (iframeCW != null && iframeCW.onReadMsg != null) {
		iframeCW.onReadMsg(data);
	}
}

window.onbeforeunload = function() {
	if (typeof socket != 'undefined') {
		socket.disconnect();
	}
};

//Toda esta parte la traigo de chat abroad.js


function initChat(socket, id, image) {

	SOCKET = socket;
	ID = id;
	IMG = image;


	/*
	Comentario manu
	// Reseteamos en nNews global

	if (parent.resetNewMessages != null) {
		parent.resetNewMessages();
	}
	*/

	$.ajax({
		url : 'chat/getChatUsers',
		dataType : 'json',
		data : {
		},
		success : function(data) {
			console.log(data);
			$.map(data.users, function(user) {
				if (user.id > 0 && user.id != ID) {
					user.noreadeds = new Array();
					users[user.id] = user;
					users[user.id].mensajes = [];
					addRoomTab(user);
					//addRoom(user);
					addOldMessages(user.id);
				}
			});
			if (data.users.length == 0) {
				$('#chat-add').tooltip('open');
			}
		}
	});

};



function addRoomTab(user) {

	var $roomTabs = $('#lista_usuarios');

	getTemplate('js/templates/room_tab.handlebars', function(template) {
		$roomTabs.append(template({
			'user' : user
		}));

		$('.chats-frame').jScrollPane();
	});

	// Scroll down tabs list
	$roomTabs.parent().animate({
		scrollTop : $roomTabs.height()
	});

};


/*
// Añadir una sala para el usuario
function addRoom(user, activate) {
	getTemplate('js/templates/room.handlebars', function(template) {
		$('#rooms').append(template({
			user : user
		}));
		if (activate) {
			activateTab(user.id);
		}
	});
};
*/


// Obtener y generar una plantilla
function getTemplate(path, callback) {
	var source;
	var template;
	// Check first if we've the template cached
	if (_.has(templates, path)) {
		if (callback)
			callback(templates[path]);
		// If not we get and compile it
	} else {
		$.ajax({
			url : path,
			cache : false,
			success : function(data) {
				source = data;
				template = Handlebars.compile(source);
				// Store compiled template in cache
				templates[path] = template;
				if (callback)
					callback(template);
			}
		});
	}
}


/*
function addOldMessages(userId) {

	$.ajax({
		url : 'ajax.php',
		dataType : 'json',
		data : {
			action : 'getOldMessages',
			user : userId
		},
		success : function(data) {

			var messages = data.messages;
			var nNews = 0;

			getTemplate('chat/js/templates/message.handlebars', function(
					template) {

				var room_messages = $('#rooms .chat-room[data-id="' + userId
						+ '"] .messages-list');

				$.map(messages, function(m) {

					var roomId;
					var remit;
					var image;
					if (m.user == ID) {
						roomId = m.destination;
						remit = 'me';
						image = IMG;
					} else {
						roomId = m.user;
						remit = 'him';
						image = users[roomId].image;
					}

					var date = moment(m.received);

					var message = {
						id : autoId++,
						serverId : m.id,
						text : m.name,
						from : m.user,
						type : m.type,
						date : m.received
					};

					switch (parseInt(message.type)) {
					case 1:
						message.typeText = true;
						break;
					case 2:
						message.typeImg = true;
						break;
					case 3:
						message.typeLoc = true;
						break;
					}

					var tempVars = template({
						message : message,
						image : image,
						date : date.calendar(),
						remit : remit
					});

					$(room_messages).prepend(tempVars);

					// Trackin del mensaje

					// Si yo soy el remitente
					if (m.user == ID) {

						// Un aspa para todos puesto que estan en la
						// base de datos
						var $message = $('#message-' + message.id);
						$message.addClass('message-sent');

						// Dos aspas para los que estén como
						// recibidos
						if (m.tracking == 2) {
							$message.addClass('message-received');
						}
					} else {
						// Si el tracking es uno lo guardamos en no readeds e
						// incrementamos el badge
						if (m.tracking == 1) {
							nNews++;
							user = users[userId];
							user.noreadeds.push(m.id);
						}
					}

				});

				if (nNews > 0) {
					increaseBadge(userId, nNews);
					// Incrementamos el badge principal pero no alertamos
					if (parent.increaseNewMessages != null) {
						parent.increaseNewMessages(nNews, false);
					}
				}

				room_messages.parent().children('.messages-loading').hide();

			});

		}
	});

};

*/


function addOldMessages(userId) {

	$.ajax({
		url : 'chat/getOldMessages',
		dataType : 'json',
		data : {},
		success : function(data) {
			var messages = data.messages;
			$.map(messages, function(m) {
				var roomId;
				var remit;
				var image;
				if (m.user == ID) {
					roomId = m.destination;
					remit = 'me';
					image = IMG;
				} else {
					roomId = m.user;
					remit = 'him';
					image = users[roomId].imagen;
				}

				var date = moment(m.received);

				var message = {
					id : autoId++,
					serverId : m.id,
					text : m.texto,
					from : m.user,
					date : m.received
				};
				users[userId].mensajes.append(message)
			});

		}

	});
};
