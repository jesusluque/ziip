# -*- coding: utf-8 -*-

from django.db import models
from datetime import datetime, date
from portal.core.constantes import *


class Usuarios(models.Model):
    token = models.CharField(max_length=250) #token para acceder en cada peticion
    num_telefono = models.CharField(max_length=250)
    fecha_registro = models.DateField(blank=True, null=True, default=datetime.now)
    usuario = models.CharField(max_length=250)
    email = models.EmailField(max_length=250)
    password = models.CharField(max_length=250)
    codigo = models.CharField(max_length=250) #Para confirmar el movil
    confirmado = models.BooleanField(default=False)
    imagen = models.CharField(max_length=250)
    
class Tokens(models.Model):
    usuario = models.ForeignKey(Usuarios)
    token = models.EmailField(max_length=250)
    tipo_dispositivo = models.CharField(max_length=2, choices = valores["tipos_dispositivos"].items(),default=TIPO_DISPOSITIVO_IOS)
    
class ChatMensajes(models.Model):
    texto = models.TextField()
    fecha = models.DateTimeField(blank=True, null=True, default=datetime.now)
    recibido = models.DateTimeField(blank=True, null=True, default=datetime.now)
    usuario = models.IntegerField()
    destinatario = models.IntegerField()
    tipo = models.IntegerField()
    bloqueado = models.IntegerField()
    enviado = models.DateTimeField(blank=True, null=True)
    leido = models.DateTimeField(blank=True, null=True)

class ChatBloqueos(models.Model):
    usuario = models.IntegerField()
    bloqueado = models.IntegerField()
    
    
"""
class SolicitudesRegistro(models.Model):
    num_telefono = models.CharField(max_length=250)
    token = models.CharField(max_length=250)
    codigo = models.CharField(max_length=250)
    fecha_solicitud = models.DateField(blank=True, null=True, default=datetime.now)
    aceptado = models.BooleanField(default=False)
    fecha_aceptacion = models.DateField(blank=True, null=True)
    

    
class SolicitudBang(models.Model):
    usuario = models.ForeignKey(Usuarios)
    num_telefono = models.EmailField(max_length=250)
    fecha_solicitud = models.DateField(blank=True, null=True, default=datetime.now)
    estado = models.CharField(max_length=2, choices = valores["estado_solicitud_bang"].items(),default=SOLICITUD_BANG_PENDIENTE)
    
    

"""    