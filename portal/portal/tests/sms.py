# -*- coding: utf-8 -*-
#!/usr/bin/env python
import os
import sys

sys.path.append(os.path.dirname(os.path.abspath(__file__)) + '/../..')
sys.path.append(os.path.dirname(os.path.abspath(__file__)) + '/..')
os.environ['DJANGO_SETTINGS_MODULE'] = 'portal.settings'

from core.models import *
from api.views import *


mensaje="Esto es una prueba de ziip con acentos áéíóú "
telefono = "616927956"
""" 
envio = EnviosSMS()
envio.telefono = limpiaTelefono(telefono)
envio.texto = mensaje
envio.save()
"""
envio = EnviosSMS.objects.get(pk=5)


enviaSMS(envio)

