var agent = require('./apn');
var agent_dev = require('./apn_dev');
var GCM = require('./gcm');

var gcm = new GCM("");//Falta el codigo para las apps android

sendNotification = function(connection, userId, text, data) {
    //Primero comprobamos si el usuario tiene activas las notificaciones


    sql = 'select id, pref_chat_notif as chat_notifications,gcmcode,gcmcode_dev, device from app_users where id=' + userId;

    console.log(sql);
    connection.query(sql, function(err, rows) {
        if (err) {
            return console.log('newEventerror en notificaciones', JSON.stringify({
                'sql': sql,
                'error': err
            }));
        }

        if (rows.length > 0) {
            console.log("Tenemos linea");
            row = rows[0];
            console.log(row.chat_notifications);
            if (row.chat_notifications) {
                console.log("Notificacion activada");
                console.log("Comprobamos si hay gcmcode de desarrollo y nenviamos");
                var msg = {
                    "loc-args": {
                        "serverId": data.serverId,
                        "text": data.text,
                        "from": data.from,
                        "type": data.type,
                        "date": data.date,
                        "readed": data.readed,
                        "destination": data.destination,
                        "action": "newMessage",
                    },
                    "body": text,
                    "action": "newMessage",
                }
                if (row.gcmcode_dev != "") {
                    if (agent_dev.connected) {
                        console.log("Agente dev conectado");
                    } else {
                        console.log("Agente no conectado");
                        agent_dev.connect()
                    }
                    console.log( "enviamos a :"+ row.gcmcode_dev);
                    console.log(msg)
                    console.log(row.gcmcode_dev);
                     bla=agent_dev.createMessage()
                        .device(row.gcmcode_dev)
                        .alert(msg)
                        .sound("default")
                        .send();

                }

                if (row.gcmcode != "") {
                    console.log("gcmcode valido");
                    if (row.device == "ios") {
                        console.log("Es ios");
                        console.log("El token es:" + row.gcmcode);
                        if (agent.connected) {
                            console.log("Agente conectado");
                        } else {
                            console.log("Agente no conectado");
                            agent.connect()
                        }

                        console.log(agent.connected);
                       
                        agent.createMessage()
                            .device(row.gcmcode)
                            .alert(msg)
                            .sound("default")
                            .send();

                        //Comprobamos si hay token de desarrollo

                       
                    } else {
                        console.log("Es android");

                        var message = {
                            "serverId": data.serverId,
                            "text": data.text,
                            "fromId": data.from,
                            "type": data.type,
                            "date": data.date,
                            "readed": data.readed,
                            "destination": data.destination,
                            "action": "newMessage",
                        }

                        var msg = {
                            registration_ids: [row.gcmcode],
                            collapse_key: "newMessage",
                            time_to_live: 0,
                            data: message,
                        };
                        console.log("Enviamos android");
                        gcm.send(msg, function(err, response) {

                            console.log("la respuesta android es:" + response);
                        });
                    }
                }
            }
        } else {
            console.log("No hay registro de notificaciones para el usuario " + userId);
        }

    });

}

