# -*- coding: utf-8 -*-
from django.http import HttpResponse, HttpResponseRedirect
from portal.core.models import *
from django.views.decorators.csrf import csrf_exempt
from portal.settings import *
from django.template.loader import render_to_string
from portal.web.titulos import *
from django.middleware.csrf import get_token
import hashlib
from django.template.defaultfilters import register


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
        lista_usuarios = Usuarios.objects.filter(email=request.POST["email"],password=request.POST["password"])
    else:
        lista_usuarios=[]

    if len(lista_usuarios)>0:
        usuario = lista_usuarios[0]
        request.session['user_id'] = usuario.id

        return redirect('/home')
    else:
        csrf_token_value = get_token(request)
        data = {"csrf_token_value":csrf_token_value,"error_login":True}
        rendered = render_to_string("login.html",data)
        return base(request,rendered,"login")


def registro(request):
    csrf_token_value = get_token(request)
    data={"csrf_token_value":csrf_token_value}
    rendered = render_to_string("registro.html",data)
    return base(request,rendered,"registro")


@loginRequired()
def home(request):
    data={}
    rendered = render_to_string("home.html",data)
    return base(request,rendered,"home")

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
