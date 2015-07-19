# -*- coding: utf-8 -*-
from django.http import HttpResponse, HttpResponseRedirect
from django.core.mail import EmailMultiAlternatives
from portal.core.models import *
from django.views.decorators.csrf import csrf_exempt
import json
import random
import time
from portal.settings import *
import httplib,urllib
from django.template.loader import render_to_string
from portal.core.celery_tasks import *

    
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

def enviaSmsCodigo(telefono,codigo,id_alta):
    mensaje="Su codigo para Ziip es: "+codigo
    
    envio = EnviosSMS()
    envio.telefono = limpiaTelefono(telefono)
    envio.texto = mensaje
    envio.save()
    enviaSMS.apply_async(args=[envio], queue=QUEUE_DEFAULT)
        


@csrf_exempt
def login(request):
    dict_usuario={}
    user_token=""
    usuarios = Usuarios.objects.filter(usuario=request.POST["user"], password=request.POST["password"])
    if len(usuarios)>0:
        status = "ok"
        usuario = usuarios[0]
        usuario.token = generaTokenUsuario()
        usuario.save()
        user_token = usuario.token
        telefono=""
        if usuario.confirmado:
            telefono=usuario.num_telefono
        dict_usuario = {"telefono":telefono or "","email":usuario.email or "","imagen":usuario.imagen or ""}
        
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

    response = json.dumps({"resource":"login","status":status, "token":user_token,"mensaje":mensaje, "usuario":dict_usuario})
    return HttpResponse(response)


@csrf_exempt
def alta(request):
    lista_usuarios = Usuarios.objects.filter(usuario=request.POST["user"])  
    mensaje=""
    token_usuario=""
    if len(lista_usuarios) == 0:
        usuario = Usuarios()
        usuario.usuario = request.POST["user"]
        usuario.password = request.POST["password"]
        usuario.email = request.POST["email"]
        usuario.sexo = request.POST["sexo"]
        
        if request.POST["movil"] != "":
            usuario.num_telefono = request.POST["movil"]
            usuario.codigo = generaCodigoSolicitud()
            enviaSmsCodigo(request.POST["movil"],usuario.codigo, usuario.id)
        
        usuario.fecha_registro = datetime.now()
        usuario.token = generaTokenUsuario()
        usuario.save()
        token_usuario = usuario.token
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
        
    
    response = json.dumps({"resource":"alta","status":status, "token":token_usuario,"mensaje":mensaje})
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
            enviaSmsCodigo(request.POST["movil"],usuario.codigo, usuario.id)
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
            usuario.save()

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
            mensaje_anonimo = request.POST["mensaje_anonimo"].encode('utf-8')
            mensaje = request.POST["mensaje"].encode('utf-8')
            
            peticion = Peticiones()
            peticion.usuario_id = usuario.pk
            peticion.tipo = TIPO_PETICION_ANONIMO
            peticion.contacto_nombre = request.POST["nombre1"]
            
            if request.POST["telefono"]=="":
                contacto = request.POST["email"]
            else:
                contacto = request.POST["telefono"]
            peticion.contacto_contacto = contacto
            
            
            
            peticion.mensaje = request.POST["mensaje"].encode('utf-8')
            peticion.mensaje_anonimo = request.POST["mensaje_anonimo"].encode('utf-8')
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

            peticion = Peticiones()
            peticion.usuario_id = usuario.pk
            peticion.tipo = TIPO_PETICION_CONECTA
            peticion.contacto_nombre = request.POST["nombre1"]
            
            if request.POST["telefono"]=="":
                contacto = request.POST["email"]
            else:
                contacto = request.POST["telefono"]
            peticion.contacto_contacto = contacto
            
            
            peticion.estado = ESTADO_PETICION_SOLICITADO
            peticion.save()
            
            enviaPeticion(peticion)
            
        else:
            status = "ko"
            mensaje = "no hay usuario"
    else:
        status = "ko"
        mensaje = "no hay token"
    response = json.dumps({"resource":"sendConecta","status":status,"mensaje":mensaje,"motivo_error":motivo_error})
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
            
            telefono = request.POST["telefono1"]
            email = request.POST["email1"]
            mensaje_anonimo = request.POST["mensaje_anonimo"]
            mensaje = request.POST["mensaje"]
            
            peticion = Peticiones()
            peticion.usuario_id = usuario.pk
            peticion.tipo = TIPO_PETICION_CELESTINO

            
            peticion.contacto_nombre = request.POST["nombre1"]
            
            if request.POST["telefono1"]=="":
                contacto = request.POST["email1"]
            else:
                contacto = request.POST["telefono1"]
            peticion.contacto_contacto = contacto
            peticion.contacto2_nombre = request.POST["nombre2"]
            
            if request.POST["telefono2"]=="":
                contacto2 = request.POST["email2"]
            else:
                contacto2 = request.POST["telefono2"]
            peticion.contacto2_contacto = contacto2
            
            
            
            peticion.mensaje = request.POST["mensaje"].encode('utf-8')
            peticion.mensaje_anonimo = request.POST["mensaje_anonimo"].encode('utf-8')
            peticion.estado = ESTADO_PETICION_SOLICITADO
            peticion.save()
            
            enviaPeticion(peticion)
            
        else:
            status = "ko"
            mensaje = "no hay usuario"
    else:
        status = "ko"
        mensaje = "no hay token"
    response = json.dumps({"resource":"sendCelestino","status":status,"mensaje":mensaje,"motivo_error":motivo_error})
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
                con["imagen"]=contacto.usuario2.imagen or ""
                lista_contactos.append(con)
            
        else:
            status = "ko"
            mensaje = "no hay usuario"
    else:
        status = "ko"
        mensaje = "no hay token"
    response = json.dumps({"resource":"getContactos","status":status,"mensaje":mensaje,"contactos":lista_contactos})
    return HttpResponse(response)
               
    
def getRecientes(request):
    
    status = "ok"
    mensaje = ""   
    lista_recientes=[]
    motivo_error = ""
    if request.META.has_key("HTTP_X_AUTH_TOKEN"):
        token = request.META["HTTP_X_AUTH_TOKEN"]
        lista_usuarios = Usuarios.objects.filter(token=request.META["HTTP_X_AUTH_TOKEN"])
        if len(lista_usuarios)>0:
            usuario = lista_usuarios[0]
            
            recientes = Peticiones.objects.filter(usuario_id = usuario.pk).order_by("-id")
            
            for reciente in recientes:
                con = {}
                con["id"]=reciente.id
                con["tipo"]=reciente.tipo
                con["contacto1_contacto"] = reciente.contacto_contacto
                con["contacto1_nombre"] = reciente.contacto_nombre
                con["contacto2_contacto"] = reciente.contacto2_contacto
                con["contacto2_nombre"] = reciente.contacto2_nombre
                con["mensaje"] = reciente.mensaje
                con["mensaje_anonimo"] = reciente.mensaje_anonimo
                con["fecha"] = str(reciente.fecha)
                
                lista_recientes.append(con)
        else:
            status = "ko"
            mensaje = "no hay usuario"
    else:
        status = "ko"
        mensaje = "no hay token"
    response = json.dumps({"resource":"getRecientes","status":status,"recientes":lista_recientes})
    return HttpResponse(response)


def enviaPeticion(peticion):
    

    if peticion.tipo == TIPO_PETICION_ANONIMO:
        if isTelefono(peticion.contacto_contacto):
            mensaje = "Te han enviado: "+peticion.mensaje_anonimo+". ziip.es contacto anonimo y seguro. Mas info http://ziip.es/"+str(peticion.codigo)
            
            envio = EnviosSMS()
            envio.telefono = limpiaTelefono(peticion.contacto_contacto)
            envio.texto = mensaje
            envio.save()
            enviaSMS.apply_async(args=[envio], queue=QUEUE_DEFAULT)

        else:
            data = {"codigo_peticion":peticion.codigo,"mensaje_anonimo":peticion.mensaje_anonimo}
            rendered = render_to_string("mails/peticion.html", data)
            asunto = "Tienes un mensaje de alguien a quien conoces. (ziip.es)"
            enviaMail.apply_async(args=[peticion.contacto_contacto,asunto,rendered], queue=QUEUE_DEFAULT)
    
    elif peticion.tipo == TIPO_PETICION_CONECTA:
        if isTelefono(peticion.contacto_contacto):
            mensaje = "Te ha invitado a usar nuestra aplicación. Primera plataforma de contacto anónima. http://ziip.es"
            envio = EnviosSMS()
            envio.telefono = limpiaTelefono(peticion.contacto_contacto)
            envio.texto = mensaje
            envio.save()
            enviaSMS.apply_async(args=[envio], queue=QUEUE_DEFAULT)
        else:
            data = {}
            rendered = render_to_string("mails/conecta.html", data)
            asunto = "Invitación a ziip.es "
            enviaMail.apply_async(args=[peticion.contacto_contacto,asunto,rendered], queue=QUEUE_DEFAULT)
        
    elif peticion.tipo == TIPO_PETICION_CELESTINO:
        if isTelefono(peticion.contacto_contacto):
            mensaje = "Te han enviado: "+peticion.mensaje_anonimo+". ziip.es contacto anonimo y seguro. Mas info http://ziip.es/"+str(peticion.codigo)
            envio = EnviosSMS()
            envio.telefono = limpiaTelefono(peticion.contacto_contacto)
            envio.texto = mensaje
            envio.save()
            enviaSMS.apply_async(args=[envio], queue=QUEUE_DEFAULT)
        else:
            data = {"codigo_peticion":peticion.codigo,"mensaje_anonimo":peticion.mensaje_anonimo}
            rendered = render_to_string("mails/peticion.html", data)
            asunto = "Tienes un mensaje de alguien a quien conoces. (ziip.es)"
            enviaMail.apply_async(args=[peticion.contacto_contacto,asunto,rendered], queue=QUEUE_DEFAULT)
            
        if isTelefono(peticion.contacto2_contacto):
            mensaje = "Te han enviado: "+peticion.mensaje_anonimo+". ziip.es contacto anonimo y seguro. Mas info http://ziip.es/"+str(peticion.codigo)
            envio = EnviosSMS()
            envio.telefono = limpiaTelefono(peticion.contacto2_contacto)
            envio.texto = mensaje
            envio.save()
            enviaSMS.apply_async(args=[envio], queue=QUEUE_DEFAULT)
        else:
            data = {"codigo_peticion":peticion.codigo,"mensaje_anonimo":peticion.mensaje_anonimo}
            rendered = render_to_string("mails/peticion.html", data)
            asunto = "Tienes un mensaje de alguien a quien conoces. (ziip.es)"
            enviaMail.apply_async(args=[peticion.contacto2_contacto,asunto,rendered], queue=QUEUE_DEFAULT)
    
    

    """
    peticion = Peticiones()
    peticion.usuario_id = usuario.pk
    peticion.tipo = TIPO_PETICION_ANONIMO
    peticion.contacto_nombre = request.POST["nombre1"]
    
    if request.POST["telefono"]=="":
        contacto = request.POST["email"]
    else:
        contacto = request.POST["telefono"]
    peticion.contacto_contacto = contacto
    
    
    
    peticion.mensaje = request.POST["mensaje"]
    peticion.mensaje_anonimo = request.POST["mensaje_anonimo"]
    """
    
def isTelefono(contacto):
    
    telefono = limpiaTelefono(contacto)
    
    if len(telefono)==9 and telefono.isdigit():
        return True
    else:
        return False
    
def limpiaTelefono(telefono):
    return telefono.replace("+34","").replace(" ","")
    
    
    
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
    
    
    
    
    
    
    
