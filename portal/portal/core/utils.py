# -*- coding: utf-8 -*-
import random
from datetime import timedelta, date
from portal.core.models import *
from portal.core.celery_tasks import *

CARACTERES_TOKEN = 'abcdefghijklmnopqrstuvwxyz1234567890'
NUM_CARACTERES_TOKEN = 20
CARACTERES_CODIGO = '1234567890'
NUM_CARACTERES_CODIGO = 6
NUM_CARACTERES_PASS = 8

def loginRequired():
    def decorator(a_view):
        def _wrapped_view(request, *args, **kwargs):
            if request.session.has_key("user_id"):
                return a_view(request, *args, **kwargs)
            return HttpResponseRedirect('/login')
        return _wrapped_view
    return decorator

def generaTokenSolicitud():
    token = ''
    i=0
    while i<NUM_CARACTERES_TOKEN:
        v = CARACTERES_TOKEN[random.randint(1,len(CARACTERES_TOKEN)-1)]
        token=token+v
        i=i+1
    return token

def generaPassword():
    token = ''
    i=0
    while i<NUM_CARACTERES_PASS:
        v = CARACTERES_TOKEN[random.randint(1,len(CARACTERES_TOKEN)-1)]
        token=token+v
        i=i+1
    return token

def generaTokenUsuario():
    token = ''

    while token == '':
        i=0
        while i<NUM_CARACTERES_TOKEN:
            v = CARACTERES_TOKEN[random.randint(1,len(CARACTERES_TOKEN)-1)]
            token=token+v
            i=i+1
        lista_usuarios = Usuarios.objects.filter(token=token)
        if len(lista_usuarios)>0:
            token=''


    return token

def generaCodigoSolicitud():
    token = ''
    i=0
    while i<NUM_CARACTERES_CODIGO:
        v = CARACTERES_CODIGO[random.randint(1,len(CARACTERES_CODIGO)-1)]
        token=token+v
        i=i+1
    return token

def enviaSmsCodigo(telefono,codigo):
    mensaje="Su codigo para Ziip es: "+codigo

    envio = EnviosSMS()
    envio.telefono = limpiaTelefono(telefono)
    envio.texto = mensaje
    envio.save()
    enviaSMS.apply_async(args=[envio], queue=QUEUE_DEFAULT)

def isTelefono(contacto):

    telefono = limpiaTelefono(contacto)

    if len(telefono)==9 and telefono.isdigit():
        return True
    else:
        return False

def limpiaTelefono(telefono):
    return telefono.replace("+34","").replace(" ","")



def enviaPeticion(peticion):
    enviamos1=True
    enviamos2=True

    rechazos1 = Rechazos.objects.filter(contacto=limpiaTelefono(peticion.contacto_contacto),general=True,confirmado=True)
    if len(rechazos1)>0:
        enviamos1=False
    else:
        rechazos1 = Rechazos.objects.filter(contacto=limpiaTelefono(peticion.contacto_contacto),general=False,usuario_id=peticion.usuario_id,confirmado=True)
        if len(rechazos1)>0:
            enviamos1=False

    if peticion.tipo == TIPO_PETICION_CELESTINO:
        rechazos2 = Rechazos.objects.filter(contacto=limpiaTelefono(peticion.contacto2_contacto),general=True,confirmado=True)
        if len(rechazos2)>0:
            enviamos2=False
        else:
            rechazos2 = Rechazos.objects.filter(contacto=limpiaTelefono(peticion.contacto2_contacto),general=False,usuario_id=peticion.usuario_id,confirmado=True)
            if len(rechazos2)>0:
                enviamos2=False

    if peticion.tipo == TIPO_PETICION_ANONIMO:
        if enviamos1:

            if isTelefono(peticion.contacto_contacto):
                mensaje = "Te han enviado: "+peticion.mensaje_anonimo+". ziip.es contacto anonimo y seguro. Mas info http://ziip.es/"+str(peticion.codigo)



                envio = EnviosSMS()
                envio.telefono = limpiaTelefono(peticion.contacto_contacto)
                envio.texto = mensaje
                envio.save()
                enviaSMS.apply_async(args=[envio], queue=QUEUE_DEFAULT)

            else:
                data = {"codigo_peticion":peticion.codigo,"mensaje_anonimo":peticion.mensaje_anonimo, "username":peticion.usuario.usuario}
                rendered = render_to_string("mails/peticion.html", data)
                asunto = "Tienes un mensaje de alguien a quien conoces. (ziip.es)"
                enviaMail.apply_async(args=[peticion.contacto_contacto,asunto,rendered], queue=QUEUE_DEFAULT)

    elif peticion.tipo == TIPO_PETICION_CONECTA:
        if enviamos1:
            if isTelefono(peticion.contacto_contacto):
                mensaje = "Te ha invitado a usar nuestra aplicación. Primera plataforma de contacto anónima. http://ziip.es"
                envio = EnviosSMS()
                envio.telefono = limpiaTelefono(peticion.contacto_contacto)
                envio.texto = mensaje
                envio.save()
                enviaSMS.apply_async(args=[envio], queue=QUEUE_DEFAULT)
            else:
                data = { "username":peticion.usuario.usuario}
                rendered = render_to_string("mails/conecta.html", data)
                asunto = "Invitación a ziip.es "
                enviaMail.apply_async(args=[peticion.contacto_contacto,asunto,rendered], queue=QUEUE_DEFAULT)

    elif peticion.tipo == TIPO_PETICION_CELESTINO:
        if enviamos1:
            if isTelefono(peticion.contacto_contacto):
                mensaje = "Te han enviado: "+peticion.mensaje_anonimo+". ziip.es contacto anonimo y seguro. Mas info http://ziip.es/"+str(peticion.codigo)
                envio = EnviosSMS()
                envio.telefono = limpiaTelefono(peticion.contacto_contacto)
                envio.texto = mensaje
                envio.save()
                enviaSMS.apply_async(args=[envio], queue=QUEUE_DEFAULT)
            else:
                data = {"codigo_peticion":peticion.codigo,"mensaje_anonimo":peticion.mensaje_anonimo, "username":peticion.usuario.usuario}
                rendered = render_to_string("mails/peticion.html", data)
                asunto = "Tienes un mensaje de alguien a quien conoces. (ziip.es)"
                enviaMail.apply_async(args=[peticion.contacto_contacto,asunto,rendered], queue=QUEUE_DEFAULT)
        if enviamos2:
            if isTelefono(peticion.contacto2_contacto):
                mensaje = "Te han enviado: "+peticion.mensaje_anonimo+". ziip.es contacto anonimo y seguro. Mas info http://ziip.es/"+str(peticion.codigo2)
                envio = EnviosSMS()
                envio.telefono = limpiaTelefono(peticion.contacto2_contacto)
                envio.texto = mensaje
                envio.save()
                enviaSMS.apply_async(args=[envio], queue=QUEUE_DEFAULT)
            else:
                data = {"codigo_peticion":peticion.codigo2,"mensaje_anonimo":peticion.mensaje_anonimo, "username":peticion.usuario.usuario}
                rendered = render_to_string("mails/peticion.html", data)
                asunto = "Tienes un mensaje de alguien a quien conoces. (ziip.es)"

                enviaMail.apply_async(args=[peticion.contacto2_contacto,asunto,rendered], queue=QUEUE_DEFAULT)

def enviaRechazo(rechazo):

    if isTelefono(rechazo.contacto):
        mensaje = "Tu codigo para aceptar el rechazo es: "+str(rechazo.codigo)
        envio = EnviosSMS()
        envio.telefono = limpiaTelefono(rechazo.contacto)
        envio.texto = mensaje
        envio.save()
        enviaSMS.apply_async(args=[envio], queue=QUEUE_DEFAULT)

    else:
        data = {"codigo_peticion":rechazo.codigo}
        rendered = render_to_string("mails/rechazoPeticion.html", data)
        asunto = "Codigo para rechazo de peticiones ziip"
        enviaMail.apply_async(args=[rechazo.contacto,asunto,rendered], queue=QUEUE_DEFAULT)
