var agent = require('./apn');
var agent_dev = require('./apn_dev');
var GCM = require('./gcm');

var gcm = new GCM("");//Falta el codigo para las apps android

sendNotification = function(connection, userId, text, data) {
    //Primero comprobamos si el usuario tiene activas las notificaciones


    sql = 'select token,tipo_dispositivo from core_tokens where usuario_id=' + userId;

    console.log(sql);
    connection.query(sql, function(err, rows) {
        if (err) {
            return console.log('newEventerror en notificaciones', JSON.stringify({
                'sql': sql,
                'error': err
            }));
        }


        console.log("Tenemos linea");
        row = rows[0];
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


        if (row.tipo_dispositivo == "1") {

                console.log("Es ios");
                console.log("El token es:" + row.token);
                if (agent.connected) {
                    console.log("Agente conectado");
                } else {
                    console.log("Agente no conectado");
                    agent.connect()
                }

                console.log(agent.connected);
                       
                agent.createMessage()
                .device(row.token)
                .alert(msg)
                .sound("default")
                .send();

                //Comprobamos si hay token de desarrollo

                       
        } else {
            /*
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
            */
            
        }
        
    });

}

