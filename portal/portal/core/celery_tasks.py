# -*- coding: utf-8 -*-

import os
import sys
from celery import Celery
from celery.task import task
from django.conf import settings
from django.template.loader import render_to_string
from django.core.mail import EmailMultiAlternatives

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
    str_from="Ziip"
    url="api.smsarena.es"
    params = urllib.urlencode({'auth_key': auth_key, 'from': str_from, 'to':envio.telefono,'text':envio.texto,"id":envio.pk,"coding":1})
    
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
    
        
    