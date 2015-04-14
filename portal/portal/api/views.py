# -*- coding: utf-8 -*-
from django.http import HttpResponse, HttpResponseRedirect
from portal.core.models import *
from django.views.decorators.csrf import csrf_exempt
import json


    
CARACTERES_TOKEN = 'abcdefghijklmnopqrstuvwxyz1234567890'
NUM_CARACTERES_TOKEN = 20
CARACTERES_CODIGO = '1234567890'
NUM_CARACTERES_CODIGO = 6
    
def test(request):
    
    return HttpResponse("prueba")
    
def generaTokenSolicitud():
    token = ''
    while i<NUM_CARACTERES_TOKEN:
        v = CARACTERES_TOKEN[random.randint(1,len(CARACTERES_TOKEN)-1)]
        token=token+v
        i=i+1
    return token
    
def generaTokenUsuario():
    token = ''
    while i<NUM_CARACTERES_TOKEN:
        v = CARACTERES_TOKEN[random.randint(1,len(CARACTERES_TOKEN)-1)]
        token=token+v
        i=i+1
    return token

def generaCodigoSolicitud():
    token = ''
    while i<NUM_CARACTERES_CODIGO:
        v = CARACTERES_CODIGO[random.randint(1,len(CARACTERES_CODIGO)-1)]
        token=token+v
        i=i+1
    return token

def enviaSmsCodigo(telefono,codigo):
    print codigo
    

@csrf_exempt
def solicitudAlta(request):
    
    telefono = request.POST["telefono"]
    solicitud = SolicitudesRegistro()
    solicitud.num_telefono = telefono
    solicitud.token = generaTokenSolicitud()
    solicitud.codigo = generaCodigoSolicitud()
    solicitud.save()
    enviaSmsCodigo(telefono.solicitud.codigo)

    response = json.dumps({"status":"ok", "token":solicitud.token})
    return HttpResponse(response)
    
    
@csrf_exempt
def confirmacionAlta(request): 
    token = request.POST["token"]
    codigo = request.POST["codigo"]
    gcm_token = request.POST["gcm_token"]
    tipo_dispositivo = request.POST["tipo_dispositivo"]
    
    try:
        solicitud=SolicitudesRegistro.objects.get(token=token)
        
        if solicitud.codigo == codigo:
            #alta
            try:
                usuario = Usuarios.objects.get(num_telefono=telefono)
            except:
                usuario = Usuarios()
                usuario.token=generaTokenUsuario()
                usuario.num_telefono=telefono
                usuario.save()
            try:
                token = Tokens.objects.get(token=gcm_token)
            except:
                token = Tokens()
                token.usuario = usuario
                token.token = gcm_token
                token.tipo_dispositovo = tipo_dispositivo 
                token.save()
            status = "ok"
            msg = ""
                
        else:
            #codigo erroneo
            status = "ko"
            msg = "Código incorrecto"
            
            
    except:
        #token erroneo
        status = "ko"
        msg = "Token no existe"
        
    response = json.dumps({"status":status, "msg":msg, "token"=usuario.token}
        
    return HttpResponse(response)
    

@csrf_exempt
def solicitudBang(request):
    token = request.POST["token"]
    telefono = request.POST["telefono"]
    usuario = Usuarios.objects.get(token=token)
    usuario_solicitado = Usuarios.objects.get(num_telefono=telefono)
    estado = SOLICITUD_BANG_PENDIENTE
    solicitudes = SolicitudBang.objects.filter(usuario_id=usuario_solicitado.pk, num_telefono=usuario.telefono)
    if len(solicitudes) >0:
        solicitud = solicitudes[0]
        solicitud.estado = SOLICITUD_BANG_ACEPTADA
        solicitud.save()
        estado = SOLICITUD_BANG_ACEPTADA
    nueva_solicitud = SolicitudBang()
    nueva_solicitud.usuario = usuario.pk
    nueva_solicitud.telefono = num_telefono
    nueva_solicitud.estado = estado
    nueva_solicitud.save()
    
    response = json.dumps({"status":"ok", "estado":estado }
        
    return HttpResponse(response)
    
    
    
    
    
    
    
    
