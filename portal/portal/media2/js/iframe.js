// JavaScript Document

var socket;
var nNews = 0;
var $iframe;
var iframeCW = null;
var ID = 0;
//var chatSound = new Audio('sounds/buip.mp3');
var chatSound = new buzz.sound("sounds/buip", {
	formats: ["ogg", "mp3", "acc"]
});

$(document).ready(function() {

	$iframe = $('#iframe');
	iframeCW = document.getElementById('iframe').contentWindow;

	$(document).mousemove(function(event) {
		console.log('mosemove');
	});

});

function loginChat(user, password, id, image) {

	ID = id;

	if (typeof socket == 'undefined') {

		changeChatStatus('Connecting...');

		// alert("connecting socket");

		socket = io.connect('http://www.abroadster.com:8888');
		//socket = io.connect('http://192.168.1.133:8888');

		// Connection established
		socket.on('connect', function(data) {
			// Hacer login
			var login = {
				user : user,
				pass : password,
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
				changeChatStatus('Connected');
				getNewMessages();
				initChat(socket, ID, image);
			} else {
				changeChatStatus('Disconnected');
			}
		});

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

function initChat(socket, id, image) {
	if (iframeCW != null && iframeCW.initChat != null) {
		iframeCW.initChat(socket, id, image);
	}
}

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
