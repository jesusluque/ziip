# -*- coding: utf-8 -*-
import random
from datetime import timedelta, date
from functools import wraps
from django.utils import translation
from django.utils.translation import ugettext as _
from django.http import HttpResponse, HttpResponseRedirect

from portal.core.models import *
from portal.core.celery_tasks import *

CARACTERES_TOKEN = 'abcdefghijklmnopqrstuvwxyz1234567890'
NUM_CARACTERES_TOKEN = 20
CARACTERES_CODIGO = '1234567890'
NUM_CARACTERES_CODIGO = 6
NUM_CARACTERES_PASS = 8

def idioma():
    def decorator(func):
        def inner_decorator(request, *args, **kwargs):
            if request.GET.has_key("lang"):
                request.session["lang"] = request.GET["lang"]
            if not request.session.has_key("lang"):
                if request.META.has_key("HTTP_ACCEPT_LANGUAGE"):
                    request.session["lang"]=request.META["HTTP_ACCEPT_LANGUAGE"].split("-")[0]
                else:
                    request.session["lang"]="es"
            translation.activate(request.session["lang"])
            return func(request, *args, **kwargs)
        return wraps(func)(inner_decorator)
    return decorator

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
    mensaje=_("Su codigo para Ziip es: ")+codigo

    envio = EnviosSMS()
    envio.telefono = telefono
    envio.texto = mensaje
    envio.save()
    enviaSMS.apply_async(args=[envio], queue=QUEUE_DEFAULT)

def isTelefono(contacto):

    telefono = limpiaTelefono(contacto)

    if telefono.isdigit():
        return True
    else:
        return False

def limpiaTelefono(telefono):
    return telefono.replace("+","").replace(" ","")

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
                mensaje = _("Te han enviado: ")+peticion.mensaje_anonimo+_(". ziip.es contacto anonimo y seguro. Mas info http://ziip.es/")+str(peticion.codigo)

                envio = EnviosSMS()
                envio.telefono = peticion.contacto_contacto
                envio.texto = mensaje
                envio.save()
                enviaSMS.apply_async(args=[envio], queue=QUEUE_DEFAULT)

            else:
                data = {"codigo_peticion":peticion.codigo,"mensaje_anonimo":peticion.mensaje_anonimo, "username":peticion.usuario.usuario}
                rendered = render_to_string("mails/peticion.html", data)
                asunto = _("Tienes un mensaje de alguien a quien conoces. (ziip.es)")
                enviaMail.apply_async(args=[peticion.contacto_contacto,asunto,rendered], queue=QUEUE_DEFAULT)

    elif peticion.tipo == TIPO_PETICION_CONECTA:
        if enviamos1:
            if isTelefono(peticion.contacto_contacto):
                mensaje = _("Te ha invitado a usar ziip. Primera plataforma de contacto anónima. http://ziip.es/")+str(peticion.codigo)
                envio = EnviosSMS()
                envio.telefono = peticion.contacto_contacto
                envio.texto = mensaje
                envio.save()
                enviaSMS.apply_async(args=[envio], queue=QUEUE_DEFAULT)
            else:
                data = { "username":peticion.usuario.usuario,"codigo_peticion":peticion.codigo}
                rendered = render_to_string("mails/conecta.html", data)
                asunto = _("Invitación a ziip.es")
                enviaMail.apply_async(args=[peticion.contacto_contacto,asunto,rendered], queue=QUEUE_DEFAULT)


    elif peticion.tipo == TIPO_PETICION_CELESTINO:
        if enviamos1:
            if isTelefono(peticion.contacto_contacto):
                mensaje = _("Te han enviado: ")+peticion.mensaje_anonimo+_(". ziip.es contacto anonimo y seguro. Mas info http://ziip.es/")+str(peticion.codigo)
                envio = EnviosSMS()
                envio.telefono = peticion.contacto_contacto
                envio.texto = mensaje
                envio.save()
                enviaSMS.apply_async(args=[envio], queue=QUEUE_DEFAULT)
            else:
                data = {"codigo_peticion":peticion.codigo,"mensaje_anonimo":peticion.mensaje_anonimo, "username":peticion.usuario.usuario}
                rendered = render_to_string("mails/peticion.html", data)
                asunto = _("Tienes un mensaje de alguien a quien conoces. (ziip.es)")
                enviaMail.apply_async(args=[peticion.contacto_contacto,asunto,rendered], queue=QUEUE_DEFAULT)
        if enviamos2:
            if isTelefono(peticion.contacto2_contacto):
                mensaje = _("Te han enviado: ")+peticion.mensaje_anonimo+_(". ziip.es contacto anonimo y seguro. Mas info http://ziip.es/")+str(peticion.codigo2)
                envio = EnviosSMS()
                envio.telefono = peticion.contacto2_contacto
                envio.texto = mensaje
                envio.save()
                enviaSMS.apply_async(args=[envio], queue=QUEUE_DEFAULT)
            else:
                data = {"codigo_peticion":peticion.codigo2,"mensaje_anonimo":peticion.mensaje_anonimo, "username":peticion.usuario.usuario}
                rendered = render_to_string("mails/peticion.html", data)
                asunto = _("Tienes un mensaje de alguien a quien conoces. (ziip.es)")

                enviaMail.apply_async(args=[peticion.contacto2_contacto,asunto,rendered], queue=QUEUE_DEFAULT)

def enviaRechazo(rechazo):

    if isTelefono(rechazo.contacto):
        mensaje = _("Tu codigo para aceptar el rechazo es: ")+str(rechazo.codigo)
        envio = EnviosSMS()
        envio.telefono = rechazo.contacto
        envio.texto = mensaje
        envio.save()
        enviaSMS.apply_async(args=[envio], queue=QUEUE_DEFAULT)

    else:
        data = {"codigo_peticion":rechazo.codigo}
        rendered = render_to_string("mails/rechazoPeticion.html", data)
        asunto = _("Codigo para rechazo de peticiones ziip")
        enviaMail.apply_async(args=[rechazo.contacto,asunto,rendered], queue=QUEUE_DEFAULT)

def comprueba_limites(usuario,contacto):
    #Primero realizamos las comprobaciones de limites.
    #   - Maximo mensajes por mismo usuario (celestina y anonimo) 5, diarios. Sumando ambos.
    #   - Persona contactada, se bloquea durante 2 semanas, a la espera de respuesta.
    # Tb tiene que ser el usaurio logado
    errores=[]
    num_peticiones = Peticiones.objects.filter(usuario__pk = usuario.pk,fecha__startswith=str(date.today()))
    if len(num_peticiones)>4:
        errores.append(_("Solo puedes relizar cinco envios diarios"))

    num_peticiones = Peticiones.objects.filter(usuario_id=usuario.pk,contacto_contacto=contacto , fecha__gte=date.today()-timedelta(days=14))
    if len(num_peticiones)>0:
        errores.append(_("No puedes enviar mas de una peticion al mismo usuario en 2 semanas"))
    return errores
