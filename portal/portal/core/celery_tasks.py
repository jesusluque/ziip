# -*- coding: utf-8 -*-

import os
import sys
from celery import Celery
from celery.task import task
from django.conf import settings
from django.template.loader import render_to_string
from django.core.mail import EmailMultiAlternatives
import httplib,urllib
from django.utils.translation import ugettext as _

sys.path.append(os.path.dirname(os.path.abspath(__file__)) + '/../..')
sys.path.append(os.path.dirname(os.path.abspath(__file__)) + '/..')

# set the default Django settings module for the 'celery' program.
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'settings')
#celery = Celery('tasks', backend='amqp', broker='amqp://guest@localhost//')
celery = Celery('tasks',  broker='amqp://guest@localhost//')

from settings import *
from core.models import *

@task
def prueba():
    print "tarea celery realizada"


@task
def enviaSMS(envio):

    auth_key="JzroaddoWbG4Ag6X8dZ80ts4AImVpbhZ"
    str_from="Ziip-es"
    url="api.smsarena.es"
    params = urllib.urlencode({'auth_key': auth_key, 'from': str_from, 'to':envio.telefono,'text':envio.texto,"id":envio.pk})

    h1 = httplib.HTTPSConnection(url)
    h1.request("GET", "/http/sms.php?"+params)
    r1 = h1.getresponse()
    envio.enviado = True
    envio.num_intentos =  envio.num_intentos + 1
    envio.fecha_ultimo_intento = datetime.now()
    data = r1.read()
    print r1.status
    print data

    datos = data.split(";")
    if datos[0] == "OK":
        envio.fallido = False
    else:
        envio.fallido = True
        envio.motivo_error = datos[0]
    envio.save()

@task
def enviaMail(email,asunto,texto):

    data = {"content":texto}
    rendered = render_to_string("mails/base.html", data)
    msg = EmailMultiAlternatives(asunto, "", MAIL_FROM, [email])
    msg.attach_alternative(rendered, "text/html")
    msg.send()
    
        

@task
def peticionAceptada(peticion):

    print peticion
    print peticion.usuario
    print peticion.usuario1
    if peticion.tipo == TIPO_PETICION_CELESTINO:
        enviaPeticionAceptada.apply_async(args=[peticion.usuario1,peticion.usuario2], queue=QUEUE_DEFAULT)
    else:
        enviaPeticionAceptada.apply_async(args=[peticion.usuario1,peticion.usuario], queue=QUEUE_DEFAULT)

@task
def enviaPeticionAceptada(usuario1,usuario2):


    print "En envia peticion aceptada"
    print usuario1
    data = {"usuario":usuario1.usuario}
    rendered = render_to_string("mails/nuevoContacto.html", data)
    asunto = _("Tienes un nuevo contacto (ziip.es)")
    enviaMail.apply_async(args=[usuario2.email,asunto,rendered], queue=QUEUE_DEFAULT)

    data = {"usuario":usuario2.usuario}
    rendered = render_to_string("mails/nuevoContacto.html", data)
    asunto = _("Tienes un nuevo contacto (ziip.es)")
    enviaMail.apply_async(args=[usuario1.email,asunto,rendered], queue=QUEUE_DEFAULT)
