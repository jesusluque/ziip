# -*- coding: utf-8 -*-

import json

import os
FILE_ROOT = os.path.dirname(__file__)

TIPO_DISPOSITIVO_IOS   = "1"
TIPO_DISPOSITIVO_ANDROID  = "2"

SOLICITUD_BANG_PENDIENTE = "1"
SOLICITUD_BANG_ACEPTADA = "2"

TIPO_PETICION_ANONIMO = "1"
TIPO_PETICION_CONECTA = "2"
TIPO_PETICION_CELESTINO = "3"
TIPO_PETICION_BANG = "4"

ESTADO_PETICION_SOLICITADO = "1"
ESTADO_PETICION_ACEPTADO = "2"
ESTADO_PETICION_DENEGADO = "3"




json_data = open(os.path.join(FILE_ROOT, 'array_config.json'))
valores = json.load(json_data)