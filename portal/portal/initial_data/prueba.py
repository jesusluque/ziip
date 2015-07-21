#!/usr/bin/env python
# -*- coding: utf-8 -*-
import os
import sys
import datetime

sys.path.append(os.path.dirname(os.path.abspath(__file__)) + '/../..')
sys.path.append(os.path.dirname(os.path.abspath(__file__)) + '/..')
os.environ['DJANGO_SETTINGS_MODULE'] = 'portal.settings'

from portal.api.views import *


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
