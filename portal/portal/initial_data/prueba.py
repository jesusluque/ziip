#!/usr/bin/env python
# -*- coding: utf-8 -*-
import os
import sys
import datetime

sys.path.append(os.path.dirname(os.path.abspath(__file__)) + '/../..')
sys.path.append(os.path.dirname(os.path.abspath(__file__)) + '/..')
os.environ['DJANGO_SETTINGS_MODULE'] = 'portal.settings'

from portal.api.views import *

"""
texto= u"mensaje con acentos áéíóú"

envio = EnviosSMS()
envio.telefono = "616927956"
envio.texto = texto.encode('utf-8')
envio.save()


auth_key="JzroaddoWbG4Ag6X8dZ80ts4AImVpbhZ"
str_from="Ziip-es"
url="api.smsarena.es"



params = urllib.urlencode({'auth_key': auth_key, 'from': str_from, 'to':envio.telefono,'text':envio.texto,"id":envio.pk})




#enviaSMS.apply_async(args=[envio], queue=QUEUE_DEFAULT)

#enviaMail("manuthema.rodriguez@gmail.com","Asunto","email de prueba")
"""

errores=[]
usuario_id=154
usuario = Usuarios.objects.get(pk=usuario_id)

contacto="660133987"
num_peticiones = Peticiones.objects.filter(usuario__pk = usuario.pk,fecha__startswith=str(date.today()-timedelta(days=2)))
print num_peticiones
if len(num_peticiones)>4:
   errores.append("Solo puedes relizar cinco envios diarios")

num_peticiones = Peticiones.objects.filter(usuario_id=usuario.pk,contacto_contacto=contacto , fecha__gte=date.today()-timedelta(days=14))
if len(num_peticiones)>0:
    errores.append("No puedes enviar mas de una peticion al mismo usuario en 2 semanas")


print errores


rechazos1 = Rechazos.objects.filter(contacto=contacto,general=True,confirmado=True)

print rechazos1
