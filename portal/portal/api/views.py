# -*- coding: utf-8 -*-
from django.http import HttpResponse, HttpResponseRedirect
from portal.core.models import *
from django.views.decorators.csrf import csrf_exempt
import json
import random
import time
from portal.settings import *
    
CARACTERES_TOKEN = 'abcdefghijklmnopqrstuvwxyz1234567890'
NUM_CARACTERES_TOKEN = 20
CARACTERES_CODIGO = '1234567890'
NUM_CARACTERES_CODIGO = 6
    
def test(request):
    
    return HttpResponse("prueba")
    
def generaTokenSolicitud():
    token = ''
    i=0
    while i<NUM_CARACTERES_TOKEN:
        v = CARACTERES_TOKEN[random.randint(1,len(CARACTERES_TOKEN)-1)]
        token=token+v
        i=i+1
    return token
    
def generaTokenUsuario():
    token = ''
    
    while token == '':
        i=0
        while i<NUM_CARACTERES_TOKEN:
            v = CARACTERES_TOKEN[random.randint(1,len(CARACTERES_TOKEN)-1)]
            token=token+v
            i=i+1
        lista_usuarios = Usuarios.objects.filter(token=token)
        if len(lista_usuarios)>0:
            token=''
            
        
    return token

def generaCodigoSolicitud():
    token = ''
    i=0
    while i<NUM_CARACTERES_CODIGO:
        v = CARACTERES_CODIGO[random.randint(1,len(CARACTERES_CODIGO)-1)]
        token=token+v
        i=i+1
    return token

def enviaSmsCodigo(telefono,codigo):
    print codigo
    

@csrf_exempt
def login(request):
    usuario={}
    usuarios = Usuarios.objects.filter(usuario=request.POST["user"], password=request.POST["password"])
    if len(usuarios)>0:
        status = "ok"
        usuario = usuarios[0]
        usuario.token = generaTokenUsuario()
        usuario.save()
        user_token = usuario.token
        usuario = {"telefono":usuario.num_telefono or "","email":usuario.email or "","imagen":usuario.imagen or ""}
        
        mensaje = ""        
        if request.POST.has_key("pushToken"):
            lista_tokens = Tokens.objects.filter(token=request.POST["pushToken"])
            if len(lista_tokens)>0:
                token = lista_tokens[0]
                if token.usuario_id != usuario.pk:
                    token.usuario_id=usuario.pk
                    token.save()
            else:
                token = Tokens()
                token.usuario_id = usuario.pk
                token.token = request.POST["pushToken"]
                token.device = request.POST["device"]
                token.save()

    else:
        status = "ko"
        token = ""
        mensaje = "Usuario o password invalido"

    response = json.dumps({"resource":"login","status":status, "token":user_token,"mensaje":mensaje, "usuario":usuario})
    return HttpResponse(response)


@csrf_exempt
def alta(request):
    lista_usuarios = Usuarios.objects.filter(usuario=request.POST["user"])  
    mensaje=""
    if len(lista_usuarios) == 0:
        usuario = Usuarios()
        usuario.usuario = request.POST["user"]
        usuario.password = request.POST["password"]
        usuario.email = request.POST["email"]
        usuario.sexo = request.POST["sexo"]
        
        if request.POST["movil"] != "":
            usuario.num_telefono = request.POST["movil"]
            usuario.codigo = generaCodigoSolicitud()
            enviaSmsCodigo(request.POST["movil"],usuario.codigo)
        
        usuario.fecha_registro = datetime.now()
        usuario.token = generaTokenUsuario()
        usuario.save()
        status = "ok"
        if request.POST.has_key("pushToken"):
            lista_tokens = Tokens.objects.filter(token=request.POST["pushToken"])
            if len(lista_tokens)>0:
                token = lista_tokens[0]
                if token.usuario_id != usuario.pk:
                    token.usuario_id = usuario.pk
                    token.save()
            else:
                token = Tokens()
                token.usuario_id = usuario.pk
                token.token = request.POST["pushToken"]
                token.device = request.POST["device"]
                token.save()
    else:
        status = "ko"
        mensaje = "El usuario ya existe"
        
    
    response = json.dumps({"resource":"alta","status":status, "token":usuario.token,"mensaje":mensaje})
    return HttpResponse(response)
    
@csrf_exempt
def confirmacionMovil(request):    
    status = "ok"
    mensaje = ""   
    if request.META.has_key("HTTP_X_AUTH_TOKEN"):
        token=request.META["HTTP_X_AUTH_TOKEN"]
        lista_usuarios = Usuarios.objects.filter(token=request.META["HTTP_X_AUTH_TOKEN"])
        if len(lista_usuarios)>0:
            usuario = lista_usuarios[0]
            if usuario.codigo == request.POST["codigo"]:
                usuario.confirmado=True
                usuario.save()
            else:
                status = "ko"
                mensaje ="El codigo de confirmacion no coincide"
            
        else:
            status = "ko"
            mensaje=" no hay usuario"
        
    else:
        status = "ko"
        mensaje = "no hay token"
    response = json.dumps({"resource":"confirmacionMovil","status":status,"mensaje":mensaje})
    return HttpResponse(response)
    
    
@csrf_exempt
def editaMovil(request):  
    status = "ok"
    mensaje = ""   
    if request.META.has_key("HTTP_X_AUTH_TOKEN"):
        token=request.META["HTTP_X_AUTH_TOKEN"]
        lista_usuarios = Usuarios.objects.filter(token=request.META["HTTP_X_AUTH_TOKEN"])
        if len(lista_usuarios)>0:
            usuario = lista_usuarios[0]
            usuario.num_telefono = request.POST["movil"]
            usuario.codigo = generaCodigoSolicitud()
            usuario.save()
            enviaSmsCodigo(request.POST["movil"],usuario.codigo)
        else:
            status = "ko"
            mensaje=" no hay usuario"
    else:
        status = "ko"
        mensaje = "no hay token"
    response = json.dumps({"resource":"editaMovil","status":status,"mensaje":mensaje})
    return HttpResponse(response)    
    
    
@csrf_exempt
def editaImagen(request):      
    status = "ok"
    mensaje = ""   
    file_url = ""
    print request
    print request.FILES
    
    print request.FILES['imagen']
    
    if request.META.has_key("HTTP_X_AUTH_TOKEN"):
        token = request.META["HTTP_X_AUTH_TOKEN"]
        lista_usuarios = Usuarios.objects.filter(token=request.META["HTTP_X_AUTH_TOKEN"])
        if len(lista_usuarios)>0:
            usuario = lista_usuarios[0]
            fichero = request.FILES['imagen']
            listado = fichero.name.split(".")
            extension = listado[len(listado)-1]
            timestamp = str(int(time.time()))
            file_url = "/uploads/"+timestamp+"."+extension
            f = open(BASE_DIR+"/portal"+file_url,'w')
            f.write(fichero.read())
            f.close()
            usuario.imagen = file_url
            usuario.save

        else:
            status = "ko"
            mensaje = "no hay usuario"
    else:
        status = "ko"
        mensaje = "no hay token"
    response = json.dumps({"resource":"editaImagen","status":status,"mensaje":mensaje,"imagen":file_url})
    return HttpResponse(response)
    
    
    
@csrf_exempt
def sendMensajeAnonimo(request):      
    status = "ok"
    mensaje = ""   
    motivo_error=""
    if request.META.has_key("HTTP_X_AUTH_TOKEN"):
        token = request.META["HTTP_X_AUTH_TOKEN"]
        lista_usuarios = Usuarios.objects.filter(token=request.META["HTTP_X_AUTH_TOKEN"])
        if len(lista_usuarios)>0:
            usuario = lista_usuarios[0]
            
            telefono = request.POST["telefono"]
            email = request.POST["email"]
            mensaje_anonimo = request.POST["mensaje_anonimo"]
            mensaje = request.POST["mensaje"]
            
            peticion = Peticiones()
            peticion.usuario_id = usuario.pk
            peticion.tipo = TIPO_PETICION_ANONIMO
            peticion.telefono = request.POST["telefono"]
            peticion.email = request.POST["email"]
            peticion.mensaje = request.POST["mensaje"]
            peticion.mensaje_anonimo = request.POST["mensaje_anonimo"]
            peticion.estado = ESTADO_PETICION_SOLICITADO
            peticion.save()
            
            enviaPeticion(peticion)
            
        else:
            status = "ko"
            mensaje = "no hay usuario"
    else:
        status = "ko"
        mensaje = "no hay token"
    response = json.dumps({"resource":"sendMensajeAnonimo","status":status,"mensaje":mensaje,"motivo_error":motivo_error})
    return HttpResponse(response)
    
@csrf_exempt
def sendConecta(request):      
    status = "ok"
    mensaje = ""   

    motivo_error = ""
    if request.META.has_key("HTTP_X_AUTH_TOKEN"):
        token = request.META["HTTP_X_AUTH_TOKEN"]
        lista_usuarios = Usuarios.objects.filter(token=request.META["HTTP_X_AUTH_TOKEN"])
        if len(lista_usuarios)>0:
            usuario = lista_usuarios[0]
            
            telefono = request.POST["telefono"]
            email = request.POST["email"]
            mensaje_anonimo = request.POST["mensaje_anonimo"]
            mensaje = request.POST["mensaje"]
            
            peticion = Peticiones()
            peticion.usuario_id = usuario.pk
            peticion.tipo = TIPO_PETICION_CONECTA
            peticion.telefono = request.POST["telefono"]
            peticion.email = request.POST["email"]
            peticion.mensaje = request.POST["mensaje"]
            peticion.mensaje_anonimo = request.POST["mensaje_anonimo"]
            peticion.estado = ESTADO_PETICION_SOLICITADO
            peticion.save()
            
            enviaPeticion(peticion)
            
        else:
            status = "ko"
            mensaje = "no hay usuario"
    else:
        status = "ko"
        mensaje = "no hay token"
    response = json.dumps({"resource":"sendMensajeAnonimo","status":status,"mensaje":mensaje,"motivo_error":motivo_error})
    return HttpResponse(response)


@csrf_exempt
def sendCelestino(request):      
    status = "ok"
    mensaje = ""   
    
    motivo_error = ""
    if request.META.has_key("HTTP_X_AUTH_TOKEN"):
        token = request.META["HTTP_X_AUTH_TOKEN"]
        lista_usuarios = Usuarios.objects.filter(token=request.META["HTTP_X_AUTH_TOKEN"])
        if len(lista_usuarios)>0:
            usuario = lista_usuarios[0]
            
            telefono = request.POST["telefono"]
            email = request.POST["email"]
            mensaje_anonimo = request.POST["mensaje_anonimo"]
            mensaje = request.POST["mensaje"]
            
            peticion = Peticiones()
            peticion.usuario_id = usuario.pk
            peticion.tipo = TIPO_PETICION_CELESTINO
            peticion.telefono = request.POST["telefono1"]
            peticion.email = request.POST["email1"]
            peticion.telefono2 = request.POST["telefono2"]
            peticion.email2 = request.POST["email2"]
            peticion.mensaje = request.POST["mensaje"]
            peticion.mensaje_anonimo = request.POST["mensaje_anonimo"]
            peticion.estado = ESTADO_PETICION_SOLICITADO
            peticion.save()
            
            enviaPeticion(peticion)
            
        else:
            status = "ko"
            mensaje = "no hay usuario"
    else:
        status = "ko"
        mensaje = "no hay token"
    response = json.dumps({"resource":"sendMensajeAnonimo","status":status,"mensaje":mensaje,"motivo_error":motivo_error})
    return HttpResponse(response)
    
    
def getContactos(request):
    status = "ok"
    mensaje = ""   
    lista_contactos=[]
    motivo_error = ""
    if request.META.has_key("HTTP_X_AUTH_TOKEN"):
        token = request.META["HTTP_X_AUTH_TOKEN"]
        lista_usuarios = Usuarios.objects.filter(token=request.META["HTTP_X_AUTH_TOKEN"])
        if len(lista_usuarios)>0:
            usuario = lista_usuarios[0]
            contactos = Contactos.objects.filter(usuario_id = usuario.pk)
            
            for contacto in contactos:
                con = {}
                con["id"]=contacto.usuario2.pk
                con["usuario"]=contacto.usuario2.usuario
                con["imagen"] = contacto.usuario2.imagen or ""
                lista_contactos.append(con)
            
        else:
            status = "ko"
            mensaje = "no hay usuario"
    else:
        status = "ko"
        mensaje = "no hay token"
    response = json.dumps({"resource":"getContactos","status":status,"mensaje":mensaje,"contactos":lista_contactos})
    return HttpResponse(response)
               
    


 

def enviaPeticion(peticion):
    
    pass


   
    
    
"""    
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
"""    
    
    
    
    
    
    
    
