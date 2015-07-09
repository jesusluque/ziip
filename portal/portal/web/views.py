# -*- coding: utf-8 -*-
from django.http import HttpResponse, HttpResponseRedirect
from django.views.decorators.csrf import csrf_exempt
from django.template.loader import render_to_string
from django.middleware.csrf import get_token
import hashlib
from django.template.defaultfilters import register
from django.core.exceptions import ValidationError
from django.core.validators import validate_email
from django.shortcuts import redirect

from portal.settings import *
from portal.core.models import *
from portal.web.titulos import *
from portal.core.utils import *

def loginRequired():
    def decorator(a_view):
        def _wrapped_view(request, *args, **kwargs):
            if request.session.has_key("user_id"):
                return a_view(request, *args, **kwargs)
            return HttpResponseRedirect('/login')
        return _wrapped_view
    return decorator

def base(request,rendered,seccion_activa):
    data={"content":rendered,"seccion_activa":seccion_activa, "titulo":titulos[seccion_activa],"subtitulo":subtitulos[seccion_activa]}
    rendered = render_to_string("base.html",data)
    return HttpResponse(rendered)

def index(request):
    data={}
    rendered = render_to_string("index.html",data)
    return base(request,rendered,"index")

def login(request):
    csrf_token_value = get_token(request)
    data={"csrf_token_value":csrf_token_value}
    rendered = render_to_string("login.html",data)
    return base(request,rendered,"login")

def doLogin(request):
    m = hashlib.md5()
    if request.POST.has_key("password"):
        m.update(request.POST["password"])
        md5_pass = m.hexdigest()
        #Se debe comentar esta linea
        md5_pass = request.POST["password"]
        print request.POST
        lista_usuarios = Usuarios.objects.filter(usuario=request.POST["email"],password=request.POST["password"])
    else:
        lista_usuarios=[]
    print lista_usuarios
    if len(lista_usuarios)>0:
        print "usuario ok"
        usuario = lista_usuarios[0]
        request.session['user_id'] = usuario.id
        #TODO el recordar, probar
        if request.POST.has_key("recordar"):
            print request.POST["recordar"]
            request.session.set_expiry(60 * 60 * 24 * 30) #UN MES


        return redirect('/home')
    else:
        csrf_token_value = get_token(request)
        data = {"csrf_token_value":csrf_token_value,"error_login":True}
        rendered = render_to_string("login.html",data)
        return base(request,rendered,"login")

def registro(request):
    errores=[]
    datos={}
    if request.session.has_key("errores_registro"):
        errores = request.session["errores_registro"]
    if request.session.has_key("datos_registro"):
        datos = request.session["datos_registro"]
    csrf_token_value = get_token(request)
    data={"csrf_token_value":csrf_token_value, "errores":errores, "datos":datos}
    rendered = render_to_string("registro.html",data)
    return base(request,rendered,"registro")

@loginRequired()
def home(request):
    data={}
    rendered = render_to_string("home.html",data)
    return base(request,rendered,"home")

def doAlta(request):
    errores=[]
    datos={}
    if request.POST.has_key("username") and request.POST["username"]!="":
        datos["username"] = request.POST["username"]
        lista_usuarios = Usuarios.objects.filter(usuario=datos["username"])
        if len(lista_usuarios)>0:
            errores.append("El username ya existe")
    else:
        errores.append("El username es obligatorio")
    if request.POST.has_key("email") and request.POST["email"]!="":
        datos["email"] = request.POST["email"]
        try:
            validate_email(request.POST["email"])
        except ValidationError as e:
            errores.append("El email es incorrecto")
        else:
            lista_usuarios = Usuarios.objects.filter(email=datos["email"])
            if len(lista_usuarios)>0:
                errores.append("El email ya esta en uso")
    else:
        errores.append("El email es obligatorio")

    if request.POST.has_key("password") and request.POST["password"]!="":
        if request.POST.has_key("password2") and request.POST("password") == request.POST["password2"]:
            datos["password"] = request.POST["password"]
        else:
            errores.append("Los passwords no coinciden")
    else:
        errores.append("El password es obligatorio")

    if request.POST.has_key("telefono") and request.POST["telefono"]!="":
        datos["telefono"] = request.POST["telefono"]
        if not isTelefono(request.POST["telefono"]):
            errores.append("El numero de telefono no es correcto")

    if len(errores)==0:
        usuario = Usuarios()
        usuario.usuario = atos["username"]
        usuario.email = datos["email"]
        usuario.password = datos["password"]
        usuario.sexo = request.POST["sexo"]
        if datos.has_key("telefono"):
            usuario.num_telefono = limpiaTelefono(datos["telefono"])
            usuario.codigo = generaCodigoSolicitud()
            enviaSmsCodigo(request.POST["telefono"],usuario.codigo)
        usuario.fecha_registro = datetime.now()
        usuario.save()

        request.session['user_id'] = usuario.id
        if datos.has_key("telefono"):
            return HttpResponseRedirect('/confirmaMovil')
        else:
            return HttpResponseRedirect('/home')
    else:
        request.session["errores_registro"] = errores
        request.session["datos_registro"] = datos
        return HttpResponseRedirect('/registro')


@loginRequired()
def confirmaMovil(request):
    csrf_token_value = get_token(request)
    data = {"csrf_token_value":csrf_token_value}
    rendered = render_to_string("confirmacionMovil.html",data)
    return base(request,rendered,"confirmacionMovil")

@loginRequired()
def doConfirmaMovil(request):
    confirmado = False
    lista_usuarios = Usuarios.objects.filter(id=request.session["user_id"])
    if len(lista_usuarios)>0:
        usuario = lista_usuarios[0]
        if usuario.codigo == request.POST["codigo"]:
            usuario.confirmado=True
            usuario.save()
            confirmado = True
    data = {"confirmado":confirmado}
    rendered = render_to_string("respuestaConfirmacionMovil.html",data)
    return base(request,rendered,"confirmacionMovil")

def peticion(request, codigo):
    lista_peticiones = Peticiones.objects.filter(codigo=token)
    if len(lista_peticiones)>0:
        peticion = lista_peticiones[0]
        data={"peticion":peticion}
        rendered = render_to_string("peticion.html",data)
    else:
        data={}
        rendered = render_to_string("peticionNoExiste.html",data)
    return base(request,rendered,"peticion")



def legal(request):
    texto = Textos.objects.get()
    data={"texto":texto.aviso_legal}
    rendered = render_to_string("textos.html",data)
    return base(request,rendered,"legal")

def privacidad(request):
    texto = Textos.objects.get()
    data={"texto":texto.privacidad}
    rendered = render_to_string("textos.html",data)
    return base(request,rendered,"privacidad")
