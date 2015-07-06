# -*- coding: utf-8 -*-
from django.http import HttpResponse, HttpResponseRedirect
from portal.core.models import *
from django.views.decorators.csrf import csrf_exempt
from portal.settings import *
from django.template.loader import render_to_string
   
   

def base(request,rendered,seccion_activa):
    
    data={"content":rendered,"seccion_activa":seccion_activa}
    rendered = render_to_string("base.html",data)
    return HttpResponse(rendered)
    
def home(request):
    data={}
    rendered = render_to_string("home.html",data)
    return base(request,rendered,"home")
    
def legal(request):
    texto = Textos.objects.get()
    data={"texto":texto.aviso_legal}
    rendered = render_to_string("textos.html",data)
    return base(request,rendered,"home")
    
def privacidad(request):
    texto = Textos.objects.get()
    data={"texto":texto.privacidad}
    rendered = render_to_string("textos.html",data)
    return base(request,rendered,"home")
    