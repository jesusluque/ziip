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
    
    rendered = "bla"
    return base(request,rendered,"home")
    