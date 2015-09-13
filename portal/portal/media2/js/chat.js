


var socket;
var nNews = 0;
var ID = 0;
var users = new Array();
var templates = {};
var autoId = 1;
var IMG=""
var USUARIO_SELECCIONADO=0

var TAB_INICIAL=0

/*
var chatSound = new buzz.sound("sounds/buip", {
	formats: ["ogg", "mp3", "acc"]
});
*/

function loginChat(user, password, imagen,abrir_chat) {
	TAB_INICIAL=abrir_chat;
	IMG = imagen;
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
				initChat(socket, ID);
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
			initChat(socket, ID);
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

	var from = data.from;
	var destination = data.destination;
	var remit = '';
	var image = '';
	var userId=0;
	var clase="";
	if (from == ID) {
		remit = 'me';
		userId=data.destination;
	} else {
		roomId = from;
		remit = 'him';
		userId=from;
		clase="chatui-talk-msg-highlight themed-border";

	}

	// Si ya tenemos el usuario
	if (typeof users[userId] == 'undefined') {
		users[userId] = {};
		users[userId].mensajes = [];
		users[userId].noreadeds= [];
		addUser(userId,false);
	}

	var message = {
		id : autoId++,
		serverId : data.id,
		text : data.text,
		from : data.from,
		date : data.received
	};

	users[userId].mensajes.push(message)


	if (userId == USUARIO_SELECCIONADO) {
		//si estamos en el tab seleccionado, pintamos el mensaje
		var date=moment();


		addMessage(userId, message, image, date.calendar(), clase);


	} else {
		//si no estamos en el tab seleccionado, incrementamos el tab
		//y lo agregamos a los mensajes no leidos
		users[userId].noreadeds.push(data.id)
		var $badge = $('.chat-room[data-id="' + userId+ '"] .badge');
        var no_leidos = users[userId].noreadeds
        $badge.text( no_leidos.length);
	}
	//hacemos el recMsg
	//En la version de carlos, solo lo hacia si el tab estaba activo
	var sId = {
		serverId : data.serverId
	};

	SOCKET.emit('recMsg', sId);


	/*
	var date = moment(data.date);

		// Mostramos el mensaje

		addMessage(roomId, data, image, date.calendar(), remit);

		// Si no es propio
		if (roomId == from) {
			// Si es de la sala abierta, notificamos la recepción
			if (data.from == getActiveRoomId()) {
				var sId = {
					serverId : data.serverId
				};
				console.log(' > recMsg:');
				console.log(sId);
				SOCKET.emit('recMsg', sId);
			}
			// Si no, lo guardamos en no leidos e incrementamos el badge
			else {
				user = users[data.from];
				user.noreadeds.push(data.serverId);
				increaseBadge(data.from, 1);

				// Incrementamos el badge principal y alertamos
				if (parent.increaseNewMessages != null) {
					parent.increaseNewMessages(1, true);
				}
			}
		}
		// Si es propio lo ponemos como enviado
		else {
			setSendedMessage(data.id, data.serverId);
		}
		*/
}



function onRecMsg(data) {
	setSendedMessage(data.id, data.serverId);
}

function onReadMsg(data) {
	$('.messages-list li[data-serverId="' + data.serverId + '"]').addClass(
			'message-received');
}

window.onbeforeunload = function() {
	if (typeof socket != 'undefined') {
		socket.disconnect();
	}
};

//Toda esta parte la traigo de chat abroad.js


function initChat(socket, id) {

	SOCKET = socket;
	ID = id;

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
			var existe=false;
			$.map(data.users, function(user) {
				if (user.id ==TAB_INICIAL ) {
					existe = true;
				}
				if (user.id > 0 && user.id != ID) {

					users[user.id] = user;
					users[user.id].mensajes = [];
					users[user.id].noreadeds= [];
					addRoomTab(user);
					//addRoom(user);
					addOldMessages(user.id);
				}
			});

			if (!existe) {
				addUser(TAB_INICIAL, true);
			}


		}
	});






};

function getFirstKey( data ) {
        for (elem in data )
            return elem;
 }

function addRoomTab(user) {

	var $roomTabs = $('#lista_usuarios');

	getTemplate('js/templates/room_tab.handlebars', function(template) {
		$roomTabs.append(template({
			'user' : user
		}));

		//comentado por manu
		//$('.chats-frame').jScrollPane();
		//$('#lista_usuarios').jScrollPane();
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
		data : {
			user_id:userId,
		},
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
					if (m.readed=="None") {
						users[userId].noreadeds.push(m.id)
					}
				}
				var message = {
					id : autoId++,
					serverId : m.id,
					text : m.texto,
					from : m.user,
					date : m.received
				};

				users[userId].mensajes.push(message)

			});
			var $badge = $('.chat-room[data-id="' + userId+ '"] .badge');
			var no_leidos = users[userId].noreadeds

			$badge.text( no_leidos.length);

			if (TAB_INICIAL==userId){
				activateTab(TAB_INICIAL);
			}
		}

	});
};




function activateTab(id) {

	/* comentado manu
	$('#panel-search').hide();
	$('#panel-rooms').show();

	$('#rooms_tabs li').removeClass('active');
	$('#rooms_tabs li[data-id="' + id + '"]').addClass('active');
	*/
	user = users[id];
	if (USUARIO_SELECCIONADO!=id) {
		USUARIO_SELECCIONADO = id;

		// Decrementar el main badge
		/*
		if (window != window.top) {
			if (parent.decreaseNewMessages != null) {
				parent.decreaseNewMessages(user.noreadeds.length);
			}
		}
		*/
		// Confirmar que hemos recibido los mensajes
		$.map(user.noreadeds, function(messageId) {
			var sId = {
				serverId : messageId
			};
			console.log(' > recMsg');
			console.log(sId);
			SOCKET.emit('recMsg', sId);
		})

		// Reiniciar los mensajes no leidos
		user.noreadeds.splice(0, user.noreadeds.length);

		//Limpiar el badge propio
		var $badge = $('.chat-room[data-id="' + id + '"] .badge');
		$badge.text(0);
		//$badge.css('visibility', 'hidden');
		// Poner como activo sólo ese chat
		$('a.chat-room.active ').removeClass('active');
		$('a.chat-room[data-id="' + id + '"]').addClass('active');

		//Ponemos el nombre de usuario en la cabecera
		var $usuario_seleccionado = $('#usuario_seleccionado');
		$usuario_seleccionado.text(user.username);

		//Generamos los mensajes y los ponemos en el div
		generarMensajes(id);

		// Mostrar el último mensaje
		var room_messages = $('#lista-mensajes');
		room_messages.parent().animate({
			scrollTop : room_messages.height()
		});

		// Focus input
		$('#message-text').focus();

	}
};

function generarMensajes(id) {

	var messages = users[id].mensajes;

	getTemplate('js/templates/message.handlebars', function(
			template) {

		var room_messages = $('#lista-mensajes');
		$(room_messages).html("");
		$.map(messages, function(m) {

			var roomId;
			var clase;
			var image;
			if (m.from == ID) {
				roomId = m.destination;
				clase = '';
				image = IMG;
			} else {
				roomId = m.user;
				clase = 'chatui-talk-msg-highlight themed-border';
				image = users[id].imagen;
			}
			var date = m.received;
			var tempVars = template({
				id:m.id,
				message : m.text,
				image : image,
				//date : date.calendar(),
				date:m.received,
				clase : clase
			});

			$(room_messages).append(tempVars);

		});
		room_messages.parent().animate({
			scrollTop : room_messages.height()
		});
		//$('.chatui-talk-scroll').jScrollPane();
	});
}



$(document).ready(function() {

	// Scroll a la izquierda jScrollPane
	//$('.slimScrollDiv').jScrollPane();

	// Enviar nuevo mensaje
	$('#message-form').submit(
		function(eventObject) {
			eventObject.preventDefault();

			if ($('#message-text').val() != "") {

				var userId = getActiveRoomId();
				if (userId != 0) {
					var date = moment();
					var json = {
						from: ID,
						to : userId,
						date : date
								.format('YYYY-MM-DD HH:mm:ss')
								+ ' GMT'
								+ date.format('Z'),
						text : $('#message-text').val(),
						type : 1,
						id : autoId++
					};
					console.log(' > newMsg');
					console.log(json);
					SOCKET.emit('newMsg', json);
					addMessage(userId, json, IMG, date.calendar(), '');
					users[userId].mensajes.push(json);
					$('#message-text').val('');
				}
			}
	});
});


function getActiveRoomId() {

	return USUARIO_SELECCIONADO;
};



// Añadir mensaje a una sala
function addMessage(roomId, message, image, date, clase) {
	getTemplate('js/templates/message.handlebars', function(template) {

		var room_messages = $('#lista-mensajes');

		var tempVars = template({
			id:message.id,
			message : message.text,
			image : image,
			date: date,
			clase : clase
		});

		$(room_messages).append(tempVars);
		room_messages.parent().animate({
			scrollTop : room_messages.height()
		});

	});
};


function setSendedMessage(id, sId) {

	$message = $('#message-' + id);
	$message.addClass('message-sent');
	$message.attr('data-serverId', sId);
}


function addUser(id, activar) {

	$.ajax({
			url : '/chat/getUser',
			dataType : 'json',
			data : {
				id : id
			},
			success : function(data) {
				var user = data.user;
				console.log(user);
				users[user.id]={};
				users[user.id].id = user.id;
				users[user.id].username = user.username;
				users[user.id].imagen = user.imagen;
				users[user.id].noreadeds = [];
				users[user.id].mensajes = [];



				addRoomTab(users[user.id]);
				if (activar){
					console.log("activar");

					activateTab(user.id);
				}
			}

	});

};
