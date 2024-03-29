# -*- coding: utf-8 -*-
from django.http import HttpResponse, HttpResponseRedirect
from django.core.mail import EmailMultiAlternatives
from django.views.decorators.csrf import csrf_exempt
import json
import time
from portal.settings import *
import httplib,urllib
from django.template.loader import render_to_string
from django.core.exceptions import ValidationError
from django.core.validators import validate_email
from django.utils.translation import ugettext as _

from portal.core.models import *
from portal.core.celery_tasks import *
from portal.core.utils import *

@csrf_exempt
def login(request):
    dict_usuario={}
    user_token=""
    usuarios = Usuarios.objects.filter(usuario=request.POST["user"], password=request.POST["password"])
    if len(usuarios)>0:
        status = "ok"
        usuario = usuarios[0]
        if request.POST.has_key("lang"):
            usuario.lang = request.POST["lang"]
        usuario.token = generaTokenUsuario()
        usuario.save()
        user_token = usuario.token
        telefono=""
        if usuario.confirmado:
            telefono=usuario.num_telefono
        dict_usuario = {"telefono":telefono or "","email":usuario.email or "","imagen":usuario.imagen or "", "pais_id":usuario.pais_id or ""}

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
                produccion = True
                if request.POST.has_key("env"):
                    if request.POST["env"]=="dev":
                        produccion = False
                token.produccion = produccion
                token.save()

    else:
        status = "ko"
        token = ""
        mensaje = _("Usuario o password invalido")

    response = json.dumps({"resource":"login","status":status, "token":user_token,"mensaje":mensaje, "usuario":dict_usuario})
    return HttpResponse(response)


@csrf_exempt
def alta(request):
    lista_usuarios = Usuarios.objects.filter(usuario=request.POST["user"])
    mensaje=""
    token_usuario=""
    if len(lista_usuarios) == 0:
        usuario = Usuarios()
        if request.POST.has_key("lang"):
            usuario.lang = request.POST["lang"]
        usuario.usuario = request.POST["user"]
        usuario.password = request.POST["password"]
        usuario.email = request.POST["email"]
        usuario.sexo = request.POST["sexo"]
        usuario.pais_id = request.POST["pais_id"]

        if request.POST["movil"] != "":
            usuario.num_telefono = request.POST["movil"]
            usuario.codigo = generaCodigoSolicitud()
            enviaSmsCodigo(request.POST["movil"],usuario.codigo)

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
        mensaje = _("El usuario ya existe")


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
                mensaje = _("El codigo de confirmacion no coincide")

        else:
            status = "ko"
            mensaje=_("no hay usuario")

    else:
        status = "ko"
        mensaje = _("no hay token")
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
            mensaje = _("no hay usuario")
    else:
        status = "ko"
        mensaje = _("no hay token")
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
            mensaje = _("no hay usuario")
    else:
        status = "ko"
        mensaje = _("no hay token")
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

            contacto = ""
            if request.POST["telefono"]=="":
                try:
                    validate_email(request.POST["email"])
                    contacto = request.POST["email"]
                except ValidationError as e:
                    status = "ko"
                    mensaje = _("El email es invalido")
            else:
                if isTelefono(request.POST["telefono"]):
                    contacto = request.POST["telefono"]
                else:
                    status = "ko"
                    mensaje = _("El telefono no es valido")

            limites=comprueba_limites(usuario,contacto)
            if len(limites)>0:
                status="ko"
                mensaje=limites[0]

            peticion.contacto_contacto = contacto
            
            peticion.mensaje = request.POST["mensaje"].encode('utf-8')
            peticion.mensaje_anonimo = request.POST["mensaje_anonimo"].encode('utf-8')
            peticion.estado = ESTADO_PETICION_SOLICITADO

            if status == "ok":
                peticion.save()
                enviaPeticion(peticion)
        else:
            status = "ko"
            mensaje = _("no hay usuario")
    else:
        status = "ko"
        mensaje = _("no hay token")
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

            contacto = ""
            if request.POST["telefono"]=="":
                try:
                    validate_email(request.POST["email"])
                    contacto = request.POST["email"]
                except ValidationError as e:
                    status = "ko"
                    mensaje = _("El email es invalido")
            else:
                if isTelefono(request.POST["telefono"]):
                    contacto = request.POST["telefono"]
                else:
                    status = "ko"
                    mensaje = _("El telefono no es valido")
            peticion.contacto_contacto = contacto

            limites=comprueba_limites(usuario,contacto)
            if len(limites)>0:
                status="ko"
                mensaje=limites[0]

            peticion.estado = ESTADO_PETICION_SOLICITADO

            if status == "ok":
                peticion.save()
                enviaPeticion(peticion)

        else:
            status = "ko"
            mensaje = _("no hay usuario")
    else:
        status = "ko"
        mensaje = _("no hay token")
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

            contacto = ""
            if request.POST["telefono1"]=="":
                try:
                    validate_email(request.POST["email1"])
                    contacto = request.POST["email1"]
                except ValidationError as e:
                    status = "ko"
                    mensaje = _("El email es invalido")
            else:
                if isTelefono(request.POST["telefono1"]):
                    contacto = request.POST["telefono1"]
                else:
                    status = "ko"
                    mensaje = _("El telefono no es valido")


            peticion.contacto_contacto = contacto
            peticion.contacto2_nombre = request.POST["nombre2"]

            contacto2 = ""
            if request.POST["telefono2"]=="":
                try:
                    validate_email(request.POST["email2"])
                    contacto2 = request.POST["email2"]
                except ValidationError as e:
                    status = "ko"
                    mensaje = _("El email es invalido")
            else:
                if isTelefono(request.POST["telefono2"]):
                    contacto2 = request.POST["telefono2"]
                else:
                    status = "ko"
                    mensaje = _("El telefono no es valido")
            peticion.contacto2_contacto = contacto2

            limites=comprueba_limites(usuario,contacto)
            limites=limites+comprueba_limites(usuario,contacto2)

            if len(limites)>0:
                status="ko"
                mensaje=limites[0]

            peticion.mensaje = request.POST["mensaje"].encode('utf-8')
            peticion.mensaje_anonimo = request.POST["mensaje_anonimo"].encode('utf-8')
            peticion.estado = ESTADO_PETICION_SOLICITADO
            if status == "ok":
                peticion.save()
                enviaPeticion(peticion)

        else:
            status = "ko"
            mensaje = _("no hay usuario")
    else:
        status = "ko"
        mensaje = _("no hay token")
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
            mensaje = _("no hay usuario")
    else:
        status = "ko"
        mensaje = _("no hay token")
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
            mensaje = _("no hay usuario")
    else:
        status = "ko"
        mensaje = _("no hay token")
    response = json.dumps({"resource":"getRecientes","status":status,"recientes":lista_recientes})
    return HttpResponse(response)

def getPaises(request):
    status = "ok"
    mensaje = ""
    lista_paises=[]

    paises = Paises.objects.all()
    for pais in paises:
        d_pais = {}
        d_pais["id"]=pais.id
        d_pais["pais"]=pais.pais
        d_pais["codigo_pais"]=pais.codigo_pais
        lista_paises.append(d_pais)
    response = json.dumps({"resource":"getPaises","status":status,"paises":lista_paises})
    return HttpResponse(response)




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
