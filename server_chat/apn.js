
join = require('path').join;
//pfx = join(__dirname, 'Certificados.cert');
fs = require('fs')


pfx = join(__dirname, 'CertificadosUltimo.p12');
  //, pfx = join(__dirname, 'cert/apn_developer_identity2.p12');


//cert = join(__dirname, 'certificado.cer');
//key = join(__dirname, 'clave_privada.cer');



cert = fs.readFileSync(join(__dirname, 'certificado.cer'));
key = fs.readFileSync(join(__dirname, 'clave_privada.cer'));


/*!
 * Create a new gateway agent
 */

apnagent = require('apnagent')
agent = module.exports = new apnagent.Agent();

/*!
 * Configure agent
 */
auth=
    key, key
    cert, cert

agent
    //.set(auth)
  
    .set('pfx file', pfx)
  

    //.set('cert',cert)
    //.set('key',key)

    .enable('sandbox')

    
    

  //.set('passphrase', '1234')

/*!
 * Error Mitigation
 */

agent.on('message:error', function (err, msg) {
console.log("Error en el agent");
  switch (err.name) {
    // This error occurs when Apple reports an issue parsing the message.
    case 'GatewayNotificationError':
      console.log('[message:error] GatewayNotificationError: %s', err.message);

      // The err.code is the number that Apple reports.
      // Example: 8 means the token supplied is invalid or not subscribed
      // to notifications for your application.
      if (err.code === 8) {
        console.log('    > %s', msg.device().toString());
        // In production you should flag this token as invalid and not
        // send any futher messages to it until you confirm validity
      }

      break;

    // This happens when apnagent has a problem encoding the message for transfer
    case 'SerializationError':
      console.log('[message:error] SerializationError: %s', err.message);
      break;

    // unlikely, but could occur if trying to send over a dead socket
    default:
      console.log('[message:error] other error: %s %s', err.name,err.message);
      break;
  }
});

/*!
 * Make the connection
 */

agent.connect(function (err) {
console.log("Conectando el agente");
  // gracefully handle auth problems
  if (err && err.name === 'GatewayAuthorizationError') {
    console.log('Authentication Error: %s', err.message);
    process.exit(1);
  }
  if (err){
    console.log(err.name);
    console.log(err.message);
  }

  // handle any other err (not likely)
  else if (err) {
    throw err;
  }

  // it worked!
  var env = agent.enabled('sandbox')
    ? 'sandbox'
    : 'production';

  console.log('apnagent [%s] gateway connected', env);
});
