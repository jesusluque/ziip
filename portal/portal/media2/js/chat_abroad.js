var SOCKET;
var ID = 0;
var IMG;
var users = new Array();
var autoId = 1;
var searchXhr;

function onNewMsg(data) {

	var from = data.from;
	var destination = data.destination;
	var roomId = 0;
	var remit = '';
	var image = '';

	if (from == ID) {
		roomId = destination;
		remit = 'me';
	} else {
		roomId = from;
		remit = 'him';
	}

	// Si ya tenemos el usuario
	if (typeof users[roomId] != 'undefined') {

		// Cargar la imagen
		if (remit == 'me') {
			image = IMG;
		} else {
			image = users[roomId].image;
		}

		var date = moment(data.date);

		// Mostramos el mensaje
		data.id = autoId++;
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
	}
	// Si no lo tenemos lo añadimos a la lista
	else {
		addUser(roomId, false);
	}

}

function onRecMsg(data) {
	setSendedMessage(data.id, data.serverId);
}

function onReadMsg(data) {
	$('.messages-list li[data-serverId="' + data.serverId + '"]').addClass(
			'message-received');
}

var templates = {};

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

// Inicializar chat
function initChat(socket, id, image) {

	SOCKET = socket;
	ID = id;
	IMG = image;

	// Reseteamos en nNews global
	if (parent.resetNewMessages != null) {
		parent.resetNewMessages();
	}

	$.ajax({
		url : 'ajax.php',
		dataType : 'json',
		data : {
			action : 'getChatUsers'
		},
		success : function(data) {
			console.log(data);
			$.map(data.users, function(user) {
				if (user.id > 0 && user.id != ID) {
					user.noreadeds = new Array();
					users[user.id] = user;
					addRoomTab(user);
					addRoom(user);
					addOldMessages(user.id);
				}
			});
			if (data.users.length == 0) {
				$('#chat-add').tooltip('open');
			}
		}
	});

};

// Añadir un usuario a la lista
function addRoomTab(user) {

	var $roomTabs = $('#rooms_tabs');

	getTemplate('chat/js/templates/room_tab.handlebars', function(template) {
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

// Añadir una sala para el usuario
function addRoom(user, activate) {
	getTemplate('chat/js/templates/room.handlebars', function(template) {
		$('#rooms').append(template({
			user : user
		}));
		if (activate) {
			activateTab(user.id);
		}
	});
};

// Cargar e insertar los mensajes
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

// Buscar usuarios
function searchUsers(inicio) {

	var $list = $('#search-list');
	var limit = 20;

	if (typeof searchXhr != 'undefined') {
		searchXhr.abort();
	}

	searchXhr = $
			.ajax({
				url : 'ajax.php',
				dataType : 'json',
				data : {
					action : 'searchUsersSmart',
					key : $('#search-filter-text').val(),
					inicio : inicio,
					limit : limit
				},
				beforeSend : function() {
					$list.parent().unbind('scroll');
					if (inicio == 0) {
						$list.html('');
					}
					$('#search-filter-text').addClass('searching');
				},
				success : function(data) {
					var users = data.users;

					getTemplate(
							'chat/js/templates/user.handlebars',
							function(template) {
								$.map(users, function(user) {
									var tempVars = template({
										user : user
									});

									$list.append(tempVars);
								});

								$('#search-filter-text').removeClass(
										'searching');
								if (users.length < limit) {
									// No hay más usuarios
									$list
											.append('<li class="no-more">No more results</li>');
								} else {
									// Puede haber más usuarios, se linka el
									// evento scroll
									$list.parent().scroll(bindScroll);
								}
							});

				}
			});

}

// Añadir usuario a la lista
function addUser(id, activate) {

	if (typeof users[id] == 'undefined') {
		$.ajax({
			url : 'ajax.php',
			dataType : 'json',
			data : {
				action : 'getUser',
				id : id
			},
			success : function(data) {
				var user = data.user;
				user.noreadeds = new Array();
				users[user.id] = user;
				addRoomTab(user);
				addRoom(user, activate);
				addOldMessages(user.id);
			}
		});
	} else if (activate) {
		activateTab(id);
	}
};

// Añadir mensaje a una sala
function addMessage(roomId, message, image, date, remit) {
	getTemplate('chat/js/templates/message.handlebars', function(template) {
		var room_messages = $('#rooms .chat-room[data-id="' + roomId
				+ '"] .messages-list');

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

		var template = template({
			message : message,
			image : image,
			date : date,
			remit : remit,
		});

		$(room_messages).append(template);

		// Scroll down room messages
		room_messages.parent().animate({
			scrollTop : room_messages.height()
		});
	});
};

// Setear mensaje como enviado
function setSendedMessage(id, sId) {
	$message = $('#message-' + id);
	$message.addClass('message-sent');
	$message.attr('data-serverId', sId);
}

// Incrementar el aviso para un usuario
function increaseBadge(roomId, increase) {

	var $badge = $('#rooms_tabs li[data-id="' + roomId + '"] .chat-news');
	var n = parseInt($badge.text());
	n += increase;
	$badge.text(n);
	$badge.css('visibility', 'visible');

}

// Activar sala
function activateTab(id) {

	$('#panel-search').hide();
	$('#panel-rooms').show();

	$('#rooms_tabs li').removeClass('active');
	$('#rooms_tabs li[data-id="' + id + '"]').addClass('active');

	user = users[id];

	// Decrementar el main badge
	if (window != window.top) {
		if (parent.decreaseNewMessages != null) {
			parent.decreaseNewMessages(user.noreadeds.length);
		}
	}

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

	// Limpiar el badge propio
	var $badge = $('#rooms_tabs li[data-id="' + id + '"] .chat-news');
	$badge.text(0);
	$badge.css('visibility', 'hidden');

	// Poner como activo sólo ese chat
	$('#rooms .chat-room').removeClass('active');
	$('#rooms .chat-room[data-id="' + id + '"]').addClass('active');

	// Mostrar el último mensaje
	var room_messages = $('#rooms .chat-room[data-id="' + id
			+ '"] .messages-list');
	room_messages.parent().animate({
		scrollTop : room_messages.height()
	});

	// Focus input
	$('#message-text').focus();

};

function getActiveRoomId() {
	return $('#rooms .chat-room.active').attr('data-id');
};

// Scroll Automatico
function bindScroll() {

	var $list = $('#search-list');
	var $frame = $list.parent();

	if ($frame.scrollTop() + $frame.height() > $list.height() - 50) {
		searchUsers($list.children('li').length);

		console.log('Scroll loading');
	}
}

$(document)
		.ready(

				function() {

					// Scroll a la izquierda jScrollPane
					$('.chats-frame').jScrollPane();

					$('.tooltip').tooltip({
						position : {
							my : 'center bottom',
							at : 'center top'
						}
					});

					// Change room
					$('#rooms_tabs').on('click', 'li', function() {
						var id = $(this).attr('data-id');
						activateTab(id);
					});

					// Enviar nuevo mensaje
					$('#message-form')
							.submit(
									function(eventObject) {
										eventObject.preventDefault();

										if ($('#message-text').val() != "") {

											var userId = getActiveRoomId();
											if (typeof userId != 'undefined') {
												var date = moment();
												var json = {
													to : userId,
													date : date
															.format('YYYY-MM-DD HH:mm:ss')
															+ ' GMT'
															+ date.format('Z'),
													text : $('#message-text')
															.val(),
													type : 1,
													id : autoId++
												};
												console.log(' > newMsg');
												console.log(json);
												SOCKET.emit('newMsg', json);
												addMessage(userId, json, IMG,
														date.calendar(), 'me');
												$('#message-text').val('');
											}
										}
									});

					// Agregar imagen
					$('#message-attach').click(function() {

						var userId = getActiveRoomId();
						if (typeof userId != 'undefined') {
							$('#message-image').trigger('click');
						}
						return false;
					});

					// Seleccionar imagen
					$('#message-image')
							.change(
									function() {
										var userId = getActiveRoomId();
										if (typeof userId != 'undefined') {
											var file = $('#message-image')[0].files[0];

											// Comprobamos el type
											if (file.type != 'image/png'
													&& file.type != 'image/jpeg') {
												alert('Only jpg or png images');
												return false;
											}

											var reader = new FileReader();
											reader.onload = function(evt) {
												var fileData = evt.target.result;
												var bytes = new Uint8Array(
														fileData);
												var binaryText = '';

												for ( var index = 0; index < bytes.byteLength; index++) {
													binaryText += String
															.fromCharCode(bytes[index]);
												}

												var encodeText = base64_encode(binaryText);

												var date = moment();
												var json = {
													to : userId,
													date : date
															.format('YYYY-MM-DD HH:mm:ss')
															+ ' GMT'
															+ date.format('Z'),
													text : encodeText,
													type : 2,
													id : autoId++
												};
												console.log(' > newMsg');
												console.log(json);
												SOCKET.emit('newMsg', json);
												json.image64 = true;
												addMessage(userId, json, IMG,
														date.calendar(), 'me');
											};

											reader.readAsArrayBuffer(file);
										}
									});

					// Abrir busqueda
					$('#chat-add').click(function() {
						$('#panel-rooms').hide();
						$('#panel-search').show();
						searchUsers(0);
						$('#search-filter-text').focus();
					});

					// Cerrar busqueda
					$('#search-close').click(function() {
						$('#panel-search').hide();
						$('#panel-rooms').show();
					});

					// Elegir usuario
					$('#search-list').on('click', 'li', function() {
						var id = $(this).attr('data-id');
						addUser(id, true);
					});

					// Filtrar busqueda
					$('#search-filter-text').keyup(function() {
						searchUsers(0);
					});

				});
