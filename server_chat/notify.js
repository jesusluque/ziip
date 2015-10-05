var agent = require('./apn');
//var agent_dev = require('./apn_dev');
var GCM = require('./gcm');



sendNotification = function(connection, userId, text, data) {
    //Primero comprobamos si el usuario tiene activas las notificaciones


    sql = 'select token,tipo_dispositivo, produccion from core_tokens where usuario_id=' + userId;

    console.log(sql);
    connection.query(sql, function(err, rows) {
        if (err) {
            return console.log('newEventerror en notificaciones', JSON.stringify({
                'sql': sql,
                'error': err
            }));
        }


        rows.forEach(function(row) {

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
                if (row.produccion ==1) {
                    console.log("produccion");

                    if (agent.connected) {
                        console.log("Agente conectado");
                    } else {
                        console.log("Agente no conectado");
                        agent.connect()
                    }

                    console.log(agent.connected);

                    b=agent.createMessage()
                    .device(row.token)
                    .alert(msg)
                    .sound("default")
                    .send();

                    console.log("Enviado Produccion");
                    console.log(b);
                } else {
                    if (agent_dev.connected) {
                        console.log("Agente conectado");
                    } else {
                        console.log("Agente no conectado");
                        agent_dev.connect()
                    }

                    console.log(agent_dev.connected);

                    b=agent_dev.createMessage()
                    .device(row.token)
                    .alert(msg)
                    .sound("default")
                    .send();
                    console.log("Enviado desarrollo");

                }


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
    });

}
