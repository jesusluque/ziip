#!/usr/bin/env python
# -*- coding: utf-8 -*-
import os
import sys
import datetime

sys.path.append(os.path.dirname(os.path.abspath(__file__)) + '/../..')
sys.path.append(os.path.dirname(os.path.abspath(__file__)) + '/..')
os.environ['DJANGO_SETTINGS_MODULE'] = 'portal.settings'

from portal.core.models import *

"""
usuario=Usuarios()

usuario.usuario="jesus"
usuario.password="ulises"
usuario.imagen = ""
usuario.save()

usuario=Usuarios()

usuario.usuario="miguel"
usuario.password="ulises"
usuario.imagen = ""
usuario.save()


usuario=Usuarios()

usuario.usuario="victor"
usuario.password="ulises"
usuario.imagen = ""
usuario.save()

usuario=Usuarios()

usuario.usuario="toni"
usuario.password="ulises"
usuario.imagen = ""
usuario.save()

mensaje = ChatMensajes()
mensaje.texto="Hola"
mensaje.fecha=datetime.now()
mensaje.usuario = 9
mensaje.destinatario =10
mensaje.tipo=1
mensaje.bloqueado=0
mensaje.enviado=None
mensaje.leido=None
mensaje.save()


mensaje = ChatMensajes()
mensaje.texto="Hola"
mensaje.fecha=datetime.now()
mensaje.usuario = 9
mensaje.destinatario =12
mensaje.tipo=1
mensaje.bloqueado=0
mensaje.enviado=None
mensaje.leido=None
mensaje.save()



mensaje = ChatMensajes()
mensaje.texto="Hola"
mensaje.fecha=datetime.now()
mensaje.usuario = 10
mensaje.destinatario =12
mensaje.tipo=1
mensaje.bloqueado=0
mensaje.enviado=None
mensaje.leido=None
mensaje.save()




mensaje = ChatMensajes()
mensaje.texto="Hola"
mensaje.fecha=datetime.now()
mensaje.usuario = 1
mensaje.destinatario =9
mensaje.tipo=1
mensaje.bloqueado=0
mensaje.enviado=None
mensaje.leido=None
mensaje.save()

"""


"""
contacto = Contactos()
contacto.usuario_id = 1
contacto.usuario2_id = 9
contacto.save()


contacto = Contactos()
contacto.usuario_id = 9
contacto.usuario2_id = 1
contacto.save()


contacto = Contactos()
contacto.usuario_id = 10
contacto.usuario2_id = 9
contacto.save()


contacto = Contactos()
contacto.usuario_id = 9
contacto.usuario2_id = 10
contacto.save()


contacto = Contactos()
contacto.usuario_id = 11
contacto.usuario2_id = 9
contacto.save()


contacto = Contactos()
contacto.usuario_id = 9
contacto.usuario2_id = 11
contacto.save()


contacto = Contactos()
contacto.usuario_id = 12
contacto.usuario2_id = 9
contacto.save()


contacto = Contactos()
contacto.usuario_id = 9
contacto.usuario2_id = 12
contacto.save()



contacto = Contactos()
contacto.usuario_id = 11
contacto.usuario2_id = 10
contacto.save()


contacto = Contactos()
contacto.usuario_id = 10
contacto.usuario2_id = 11
contacto.save()


contacto = Contactos()
contacto.usuario_id = 12
contacto.usuario2_id = 10
contacto.save()


contacto = Contactos()
contacto.usuario_id = 10
contacto.usuario2_id = 12
contacto.save()


contacto = Contactos()
contacto.usuario_id = 12
contacto.usuario2_id = 11
contacto.save()


contacto = Contactos()
contacto.usuario_id = 11
contacto.usuario2_id = 12
contacto.save()

mensaje = ChatMensajes()
mensaje.texto="Hola"
mensaje.fecha=datetime.now()
mensaje.usuario = 9
mensaje.destinatario =22
mensaje.tipo=1
mensaje.bloqueado=0
mensaje.enviado=None
mensaje.leido=None
mensaje.save()
"""

usuario=Usuarios()

usuario.usuario="apple"
usuario.password="ulises"
usuario.imagen = ""
usuario.save()







contacto = Contactos()
contacto.usuario_id =9
contacto.usuario2_id = 24
contacto.save()


contacto = Contactos()
contacto.usuario_id =24
contacto.usuario2_id = 9
contacto.save()
