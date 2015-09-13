# -*- coding: utf-8 -*-
from django.http import HttpResponse, HttpResponseRedirect
from django.views.decorators.csrf import csrf_exempt
from django.template.loader import render_to_string
import json
from portal.settings import *
from portal.core.models import *
from portal.core.utils import *
from django.db.models import Q

@loginRequired()
def getChatUsers (request):

    ids = ChatMensajes.objects.filter(Q(usuario=request.session["user_id"])|Q(destinatario=request.session["user_id"])).values_list('usuario', flat=True).distinct()
    ids2= ChatMensajes.objects.filter(Q(usuario=request.session["user_id"])|Q(destinatario=request.session["user_id"])).values_list('destinatario', flat=True).distinct()
    usuarios_id=[]
    for user_id in ids:
        if user_id not in usuarios_id:
            usuarios_id.append(user_id)
    for user_id in ids2:
        if user_id not in usuarios_id:
            usuarios_id.append(user_id)
    if  request.session["user_id"] in usuarios_id:
        usuarios_id.remove(request.session["user_id"])

    usuarios = Usuarios.objects.filter(pk__in=usuarios_id)

    json_usuarios=[]

    for user in usuarios:

        usuario={"id":user.id,
            "username":user.usuario,
            "imagen":user.imagen
            }
        json_usuarios.append(usuario)
    response = json.dumps({"users":json_usuarios})
    return HttpResponse(response)

@loginRequired()
def getUser (request):
    user = Usuarios.objects.get(pk__in=request.GET["id"])
    usuario={
        "id":user.id,
        "username":user.usuario,
        "imagen":user.imagen
    }

    response = json.dumps({"user":usuario})
    return HttpResponse(response)

@loginRequired()
def getOldMessages (request):
    mensajes_list = ChatMensajes.objects.filter(Q(usuario=request.GET["user_id"], destinatario=request.session["user_id"])|Q(usuario=request.session["user_id"],destinatario=request.GET["user_id"]))

    mensajes=[]

    for msg in mensajes_list:
        mensaje={
            "id":msg.id,
            "user":msg.usuario,
            "destination":msg.destinatario,
            "received":str(msg.recibido),
            "readed":str(msg.leido),
            "texto":msg.texto,
        }
        mensajes.append(mensaje)
    response = json.dumps({"messages":mensajes})
    return HttpResponse(response)
