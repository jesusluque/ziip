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
    logado = False
    if request.session.has_key("user_id"):
        logado = True
    data={"logado":logado,"content":rendered,"seccion_activa":seccion_activa, "titulo":titulos[seccion_activa],"subtitulo":subtitulos[seccion_activa]}
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
        lista_usuarios = Usuarios.objects.filter(usuario=request.POST["usuario"],password=request.POST["password"])
    else:
        lista_usuarios=[]
    if len(lista_usuarios)>0:
        print "usuario ok"
        usuario = lista_usuarios[0]
        request.session['user_id'] = usuario.id
        #TODO el recordar, probar
        if request.POST.has_key("recordar"):
            print request.POST["recordar"]
            request.session.set_expiry(60 * 60 * 24 * 30) #UN MES

        if request.session.has_key("codigo_peticion"):
            url = '/peticionPrivado?peticion='+request.session["codigo_peticion"]
            request.session.pop("codigo_peticion")
            return redirect(url)
        else:
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
        request.session.pop("errores_registro")
    if request.session.has_key("datos_registro"):
        datos = request.session["datos_registro"]
        request.session.pop("datos_registro")
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

    if request.POST.has_key("sexo") and request.POST["sexo"]!="":
        datos["sexo"] = request.POST["sexo"]

    if not request.POST.has_key("condiciones") or request.POST["condiciones"]!="1":
        errores.append("Debe aceptar las condiciones de uso")

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
            if request.session.has_key("codigo_peticion"):
                url = '/peticionPrivado?peticion='+request.session["codigo_peticion"]
                request.session.pop("codigo_peticion")
                return redirect(url)
            else:
                return HttpResponseRedirect('/home')
    else:
        request.session["errores_registro"] = errores
        request.session["datos_registro"] = datos
        return HttpResponseRedirect('/registro')


@loginRequired()
def confirmaMovil(request):
    csrf_token_value = get_token(request)
    error_confirmacionMovil=False
    if request.session.has_key("error_confirmacionMovil"):
        error_confirmacionMovil=True
        request.session.pop("error_confirmacionMovil")


    data = {"csrf_token_value":csrf_token_value,"error_confirmacionMovil":error_confirmacionMovil}
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
        else:
            request.session["error_confirmacionMovil"]=True
            return HttpResponseRedirect('/confirmaMovil')

    data = {"confirmado":confirmado}
    rendered = render_to_string("respuestaConfirmacionMovil.html",data)
    return base(request,rendered,"confirmacionMovil")

def peticion(request, codigo):
    lista_peticiones = Peticiones.objects.filter(codigo=codigo)
    if len(lista_peticiones)>0:
        peticion = lista_peticiones[0]
        data={"peticion":peticion}
        rendered = render_to_string("peticion.html",data)
    else:
        data={}
        rendered = render_to_string("peticionNoExiste.html",data)
    return base(request,rendered,"peticion")

def peticionPrivado(request):
    lista_peticiones = Peticiones.objects.filter(codigo=request.GET["peticion"])
    if len(lista_peticiones)>0:
        peticion = lista_peticiones[0]
        logado = False
        if request.session.has_key("user_id"):
            logado = True
        else:
            request.session["codigo_peticion"]=peticion.codigo
        data={"peticion":peticion,"logado":logado}


        rendered = render_to_string("peticionPrivado.html",data)
    else:
        data={}
        rendered = render_to_string("peticionNoExiste.html",data)
    return base(request,rendered,"peticion")


@loginRequired()
def aceptarContactoPeticion(request):
    lista_peticiones = Peticiones.objects.filter(codigo=request.GET["peticion"])
    if len(lista_peticiones)>0:
        peticion = lista_peticiones[0]

        contacto = Contactos()
        contacto.usuario_id = peticion.usuario_id
        contacto.usuario2_id = request.session["user_id"]
        contacto.save()

        contacto = Contactos()
        contacto.usuario_id = request.session["user_id"]
        contacto.usuario2_id = peticion.usuario_id
        contacto.save()

        request.session["error_contactos"] = "Contacto aceptado"
        return HttpResponseRedirect('/contactos')

    else:
        data = {}
        rendered = render_to_string("peticionNoExiste.html",data)
        return base(request,rendered,"peticion")

@loginRequired()
def contactos(request):
    contactos= Contactos.objects.filter(usuario_id=request.session["user_id"])
    data = {"contactos":contactos}
    rendered = render_to_string("contactos.html",data)
    return base(request,rendered,"contactos")


@loginRequired()
def recientes(request):
    recientes = Peticiones.objects.filter(usuario_id=request.session["user_id"]).order_by("-id")[:10]
    data = {"recientes":recientes}
    rendered = render_to_string("recientes.html",data)
    return base(request,rendered,"recientes")

@loginRequired()
def ziip(request):
    data = {}
    rendered = render_to_string("ziip.html",data)
    return base(request,rendered,"ziip")

@loginRequired()
def ajustes(request):
    csrf_token_value = get_token(request)
    usuario = Usuarios.objects.get(pk=request.session["user_id"])

    data = {"csrf_token_value":csrf_token_value,"usuario":usuario}
    rendered = render_to_string("ajustes.html",data)
    return base(request,rendered,"ajustes")

@loginRequired()
def saveAjustes(request):
    usuario = Usuarios.objects.get(pk=request.session["user_id"])

    #primero la imagen
    if request.FILES.has_key("imagen"):

        fichero=request.FILES['imagen']
        listado = fichero.name.split(".")
        extension = listado[len(listado)-1]
        timestamp = str(int(time.time()))
        tmp = "uploads/"+timestamp+"."+extension
        f = open(settings.BASE_DIR+"/portal/"+tmp,'w')
        f.write(fichero.read())
        f.close()


    telefono = False
    if request.POST.has_key("telefono"):
        if isTelefono(request.POST["telefono"]):
            usuario.num_telefono = limpiaTelefono(request.POST["telefono"])
            enviaSmsCodigo(request.POST["telefono"],usuario.codigo)
            telefono = True

    usuario.save()
    if telefono:
        return HttpResponseRedirect('/confirmaMovil')
    else:
        return HttpResponseRedirect('/ajustes')

@loginRequired()
def anonimo(request):
    errores={}
    datos={}
    if request.session.has_key("errores_peticion"):
        errores=request.session["errores_peticion"]
        datos=request.session["datos_peticion"]
        request.session.pop("errores_peticion")
        request.session.pop("datos_peticion")
    else:
        datos["mensaje_anonimo"]="0"

    csrf_token_value = get_token(request)
    data = {"csrf_token_value":csrf_token_value,"tipo":TIPO_PETICION_ANONIMO,"datos":datos,"errores":errores}
    rendered = render_to_string("nuevaPeticion.html",data)
    return base(request,rendered,"anonimo")

@loginRequired()
def conecta(request):
    errores={}
    datos={}
    if request.session.has_key("errores_peticion"):
        errores=request.session["errores_peticion"]
        datos=request.session["datos_peticion"]
        request.session.pop("errores_peticion")
        request.session.pop("datos_peticion")
    csrf_token_value = get_token(request)
    data = {"csrf_token_value":csrf_token_value,"tipo":TIPO_PETICION_CONECTA,"datos":datos,"errores":errores}
    rendered = render_to_string("nuevaPeticion.html",data)
    return base(request,rendered,"conecta")

@loginRequired()
def celestino(request):
    errores={}
    datos={}
    if request.session.has_key("errores_peticion"):
        errores=request.session["errores_peticion"]
        datos=request.session["datos_peticion"]
        request.session.pop("errores_peticion")
        request.session.pop("datos_peticion")
    csrf_token_value = get_token(request)
    data = {"csrf_token_value":csrf_token_value,"tipo":TIPO_PETICION_CELESTINO,"datos":datos,"errores":errores}
    rendered = render_to_string("nuevaPeticion.html",data)
    return base(request,rendered,"celestino")

@loginRequired()
def sendPeticion(request):

    errores = []
    datos={}
    usuario = Usuarios.objects.get(pk=request.session["user_id"])
    peticion = Peticiones()
    peticion.usuario_id = usuario.pk
    peticion.tipo =  request.POST["tipo_peticion"]
    datos["tipo"]=request.POST["tipo_peticion"]

    peticion.estado = ESTADO_PETICION_SOLICITADO
    contacto=""
    if request.POST["telefono"]=="":
        try:
            validate_email(request.POST["email"])
            contacto = request.POST["email"]
        except ValidationError as e:
            errores.append("El email es incorrecto")
    else:
        if isTelefono(request.POST["telefono"]):
            contacto = request.POST["telefono"]
        else:
            errores.append("El telefono no es valido")

    peticion.contacto_contacto = contacto
    peticion.contacto_nombre = request.POST["nombre"]

    datos["telefono"]=request.POST["telefono"]
    datos["email"]=request.POST["email"]
    datos["nombre"]=request.POST["nombre"]



    if request.POST["tipo_peticion"]!=TIPO_PETICION_CONECTA:

        datos["mensaje"]=request.POST["mensaje"]
        datos["mensaje_anonimo"]=request.POST["mensaje_anonimo"]

        peticion.mensaje = request.POST["mensaje"]
        mensajes={}
        if request.POST["tipo_peticion"]==TIPO_PETICION_ANONIMO:
            mensajes["1"]="Te conozco desde hace tiempo y quiero conocerte mejor."
            mensajes["2"]="Nos conocemos desde hace poco, pero no puedo olvidarte."
            mensajes["3"]="Trabajamos juntos, tenemos muchas cosas en común, charlemos."
            mensajes["4"]="Nuestras miradas se han encontrado, nuestras palabras también podrían."
            mensajes["5"]="Estudiamos juntos, y desde que te vi no te olvido."
        elif request.POST["tipo_peticion"]==TIPO_PETICION_CELESTINO:
            mensajes["1"]="Trabajo con vosotros y creo que deberíais conoceros mejor."
            mensajes["2"]="Os he visto muchas veces, se que haceis buena pareja."
            mensajes["3"]="Nos conocemos los tres y creo que os gustáis."
            mensajes["4"]="Os he visto a ambos en clase, creo que hacéis buena pareja."
        peticion.mensaje_anonimo = mensajes[request.POST["mensaje_anonimo"]]

    if request.POST["tipo_peticion"]==TIPO_PETICION_CELESTINO:

        peticion.contacto2_nombre = request.POST["nombre2"]
        contacto2=""
        if request.POST["telefono2"]=="":
            try:
                validate_email(request.POST["email2"])
                contacto2 = request.POST["email2"]
            except ValidationError as e:
                errores.append("El email del segundo contacto es incorrecto")
        else:
            if isTelefono(request.POST["telefono2"]):
                contacto2 = request.POST["telefono2"]
            else:
                errores.append("El telefono del segundo contacto no es valido")
        peticion.contacto2_contacto = contacto2

        datos["telefono2"]=request.POST["telefono2"]
        datos["email2"]=request.POST["email2"]
        datos["nombre2"]=request.POST["nombre2"]


    if len(errores)==0:

        peticion.save()
        enviaPeticion(peticion)
        #Mostramos resultado
        request.session["peticionEnviada"]=peticion.pk
        return HttpResponseRedirect('/peticionEnviada')
    else:

        #Redirigimos y mostramos los errores
        paginas={}
        paginas["1"]="/anonimo"
        paginas["2"]="/conecta"
        paginas["3"]="/celestino"
        request.session["errores_peticion"] = errores
        request.session["datos_peticion"] = datos

        return HttpResponseRedirect(paginas[request.POST["tipo_peticion"]])

@loginRequired()
def peticionEnviada(request):
    peticion=Peticiones.objects.get(pk=request.session["peticionEnviada"])
    data = {"peticion":peticion}
    paginas={}
    paginas["1"]="/anonimo"
    paginas["2"]="/conecta"
    paginas["3"]="/celestino"

    rendered = render_to_string("peticionEnviada.html",data)
    return base(request,rendered,paginas[peticion.tipo])


@loginRequired()
def chat(request):

    data = {}
    rendered = render_to_string("chat.html",data)
    return base(request,rendered,"chat")


@loginRequired()
def logout(request):
    if request.session.has_key("user_id"):
        request.session.pop("user_id")
    return HttpResponseRedirect('/')

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
