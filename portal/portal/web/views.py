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
import time
from datetime import timedelta, date
from django.utils.translation import ugettext as _

from portal.settings import *
from portal.core.models import *
from portal.web.titulos import *
from portal.core.utils import *



def base(request,rendered,seccion_activa):
    logado = False
    usuario = None
    open_chat = 0
    if request.session.has_key("user_id"):
        logado = True
    if seccion_activa == "chat":
        usuario = Usuarios.objects.get(pk=request.session["user_id"])
        usuario.chatToken=generaTokenSolicitud()
        usuario.save()
        if request.GET.has_key("open_chat"):
            open_chat = request.GET["open_chat"]

    data={"logado":logado,"content":rendered,"seccion_activa":seccion_activa,"usuario":usuario,"open_chat":open_chat}
    rendered = render_to_string("base.html",data)
    return HttpResponse(rendered)

def prueba(request):
    rendered="fallo"

    if request.GET.has_key("lang"):
        translation.activate("en_en")
        rendered = "idioma cambiado"
    return HttpResponse(rendered)

@idioma()
def index(request):
    data={}
    rendered = render_to_string("index.html",data)
    return base(request,rendered,"index")

@idioma()
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
        lista_usuarios = Usuarios.objects.filter(usuario=request.POST["usuario"],password=request.POST["password"])
    else:
        lista_usuarios=[]
    if len(lista_usuarios)>0:
        usuario = lista_usuarios[0]

        if  request.session.has_key("lang"):
            usuario.lang = request.session["lang"]

        request.session['user_id'] = usuario.id
        request.session["pais_id"] = usuario.pais_id
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

@idioma()
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
    paises = Paises.objects.all()
    data={"csrf_token_value":csrf_token_value, "errores":errores, "datos":datos, "paises":paises}
    rendered = render_to_string("registro.html",data)
    return base(request,rendered,"registro")

"""
@idioma()
@loginRequired()
def home(request):
    data={}
    rendered = render_to_string("home.html",data)
    return base(request,rendered,"home")
"""

def doAlta(request):
    errores=[]
    datos={}
    if request.POST.has_key("username") and request.POST["username"]!="":
        datos["username"] = request.POST["username"]
        lista_usuarios = Usuarios.objects.filter(usuario=datos["username"])
        if len(lista_usuarios)>0:
            errores.append(_("El username ya existe"))
    else:
        errores.append(_("El username es obligatorio"))
    if request.POST.has_key("email") and request.POST["email"]!="":
        datos["email"] = request.POST["email"]
        try:
            validate_email(request.POST["email"])
        except ValidationError as e:
            errores.append(_("El email es incorrecto"))
        else:
            lista_usuarios = Usuarios.objects.filter(email=datos["email"])
            if len(lista_usuarios)>0:
                errores.append(_("El email ya esta en uso"))
    else:
        errores.append(_("El email es obligatorio"))

    if request.POST.has_key("password") and request.POST["password"]!="":
        if request.POST.has_key("password2") and request.POST["password"] == request.POST["password2"]:
            datos["password"] = request.POST["password"]
        else:
            errores.append(_("Los passwords no coinciden"))
    else:
        errores.append(_("El password es obligatorio"))

    if request.POST.has_key("telefono") and request.POST["telefono"]!="":
        datos["telefono"] = request.POST["telefono"]
        if not isTelefono(request.POST["telefono"]):
            errores.append(_("El numero de telefono no es correcto"))

    if request.POST.has_key("sexo") and request.POST["sexo"]!="":
        datos["sexo"] = request.POST["sexo"]

    if request.POST.has_key("pais_id") and request.POST["pais_id"]!="":
        datos["pais_id"] = int(request.POST["pais_id"])
    else:
        errores.append(_("El pais es obligatorio"))


    if not request.POST.has_key("condiciones") or request.POST["condiciones"]!="1":
        errores.append(_("Debe aceptar las condiciones de uso"))

    if len(errores)==0:
        usuario = Usuarios()
        if request.session.has_key("lang"):
            usuario.lang = request.session["lang"]

        usuario.usuario = datos["username"]
        usuario.email = datos["email"]
        usuario.password = datos["password"]
        usuario.pais_id = datos["pais_id"]
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


@idioma()
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

@idioma()
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

@idioma()
def peticion(request, codigo):
    data={}
    lista_peticiones = Peticiones.objects.filter(codigo=codigo)
    if len(lista_peticiones)==0:
        lista_peticiones = Peticiones.objects.filter(codigo2=codigo)
    if len(lista_peticiones)>0:
        peticion = lista_peticiones[0]
        logado = False
        if request.session.has_key("user_id"):
            logado = True
        else:
            request.session["codigo_peticion"]=peticion.codigo
        data={"peticion":peticion,"logado":logado}
        rendered = render_to_string("peticion.html",data)
    else:
        data={}
        rendered = render_to_string("peticionNoExiste.html",data)
    return base(request,rendered,"peticion")

@idioma()
def peticionPrivado(request):
    lista_peticiones = Peticiones.objects.filter(codigo=request.GET["peticion"])
    if len(lista_peticiones)==0:
        lista_peticiones = Peticiones.objects.filter(codigo2=request.GET["peticion"])
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


@idioma()
@loginRequired()
def aceptarContactoPeticion(request):

    lista_peticiones = Peticiones.objects.filter(codigo=request.GET["peticion"])
    if len(lista_peticiones)==0:
        lista_peticiones = Peticiones.objects.filter(codigo2=request.GET["peticion"])
        usuario_logado=2
    else:
        usuario_logado=1

    if len(lista_peticiones)>0:
        peticion = lista_peticiones[0]

        if peticion.tipo == TIPO_PETICION_CELESTINO:
            if usuario_logado==1:
                peticion.usuario1_id=request.session["user_id"]
            else:
                peticion.usuario2_id=request.session["user_id"]
            peticion.save()

            if peticion.usuario1!=None and peticion.usuario2!=None:
                peticionAceptada
                contacto = Contactos()
                contacto.usuario_id = peticion.usuario1_id
                contacto.usuario2_id = peticion.usuario2_id
                contacto.save()
                contacto = Contactos()
                contacto.usuario_id = peticion.usuario2_id
                contacto.usuario2_id = peticion.usuario1_id
                contacto.save()
                peticionAceptada.apply_async(args=[peticion], queue=QUEUE_DEFAULT)
        else:
            if usuario_logado==1:
                peticion.usuario1_id=request.session["user_id"]

            peticion.save()
            contacto = Contactos()
            contacto.usuario_id = peticion.usuario_id
            contacto.usuario2_id = request.session["user_id"]
            contacto.save()

            contacto = Contactos()
            contacto.usuario_id = request.session["user_id"]
            contacto.usuario2_id = peticion.usuario_id
            contacto.save()
            peticionAceptada.apply_async(args=[peticion], queue=QUEUE_DEFAULT)

        request.session["error_contactos"] = _("Contacto aceptado")
        return HttpResponseRedirect('/contactos')

    else:
        data = {}
        rendered = render_to_string("peticionNoExiste.html",data)
        return base(request,rendered,"peticion")

@idioma()
@loginRequired()
def contactos(request):
    contactos= Contactos.objects.filter(usuario_id=request.session["user_id"])
    data = {"contactos":contactos}
    rendered = render_to_string("contactos.html",data)
    return base(request,rendered,"contactos")


@idioma()
@loginRequired()
def recientes(request):
    recientes = Peticiones.objects.filter(usuario_id=request.session["user_id"]).order_by("-id")[:10]
    data = {"recientes":recientes}
    rendered = render_to_string("recientes.html",data)
    return base(request,rendered,"recientes")

@idioma()
@loginRequired()
def reciente(request):
    reciente = Peticiones.objects.get(usuario_id=request.session["user_id"], pk=request.GET["peticion_id"])
    data = {"reciente":reciente}
    rendered = render_to_string("reciente.html",data)
    return base(request,rendered,"recientes")

@idioma()
@loginRequired()
def ziip(request):
    data = {}
    rendered = render_to_string("ziip.html",data)
    return base(request,rendered,"ziip")

@idioma()
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
        usuario.imagen=tmp


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

@idioma()
@loginRequired()
def anonimo(request):
    errores={}
    datos={}
    datos["pais_id"]=request.session["pais_id"]
    if request.session.has_key("errores_peticion"):
        errores=request.session["errores_peticion"]
        datos=request.session["datos_peticion"]
        request.session.pop("errores_peticion")
        request.session.pop("datos_peticion")
    else:
        datos["mensaje_anonimo"]="0"

    paises = Paises.objects.all()
    csrf_token_value = get_token(request)
    data = {"csrf_token_value":csrf_token_value,"tipo":TIPO_PETICION_ANONIMO,"datos":datos,"errores":errores, "paises":paises}
    rendered = render_to_string("nuevaPeticion.html",data)
    return base(request,rendered,"anonimo")

@idioma()
@loginRequired()
def conecta(request):
    errores={}
    datos={}
    datos["pais_id"]=request.session["pais_id"]
    if request.session.has_key("errores_peticion"):
        errores=request.session["errores_peticion"]
        datos=request.session["datos_peticion"]
        request.session.pop("errores_peticion")
        request.session.pop("datos_peticion")
    csrf_token_value = get_token(request)
    paises = Paises.objects.all()

    data = {"csrf_token_value":csrf_token_value,"tipo":TIPO_PETICION_CONECTA,"datos":datos,"errores":errores, "paises":paises}
    rendered = render_to_string("nuevaPeticion.html",data)
    return base(request,rendered,"conecta")

@idioma()
@loginRequired()
def celestino(request):
    errores={}
    datos={}
    datos["pais_id"]=request.session["pais_id"]
    if request.session.has_key("errores_peticion"):
        errores=request.session["errores_peticion"]
        datos=request.session["datos_peticion"]
        request.session.pop("errores_peticion")
        request.session.pop("datos_peticion")
    csrf_token_value = get_token(request)
    paises = Paises.objects.all()
    data = {"csrf_token_value":csrf_token_value,"tipo":TIPO_PETICION_CELESTINO,"datos":datos,"errores":errores, "paises":paises}
    rendered = render_to_string("nuevaPeticion.html",data)
    return base(request,rendered,"celestino")

@idioma()
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
            errores.append(_("El email es incorrecto"))
    else:
        if isTelefono(request.POST["telefono"]):
            contacto = request.POST["telefono"]
        else:
            errores.append(_("El telefono no es valido"))

    if request.POST["pais_id"]=="":
        datos["pais_id"] = session["pais_id"]
    else:
        datos["pais_id"] = int(request.POST["pais_id"])

    #Comprobamos los envios a contactos,hay que dejar 14 dias
    errores = errores + comprueba_limites(usuario,contacto)

    #peticion.contacto_contacto = contacto
    pais = Paises.objects.get(id=datos["pais_id"])
    peticion.contacto_contacto = pais.codigo_pais+contacto

    peticion.contacto_nombre = request.POST["nombre"]

    datos["telefono"]=request.POST["telefono"]
    datos["email"]=request.POST["email"]
    datos["nombre"]=request.POST["nombre"]

    if request.POST["tipo_peticion"]!=TIPO_PETICION_CONECTA:
        datos["mensaje"]=request.POST["mensaje"]
        if request.POST.has_key("mensaje_anonimo") and request.POST["mensaje_anonimo"]!="" :
            datos["mensaje_anonimo"] = request.POST["mensaje_anonimo"]
        else:
            errores.append("Debe seleccionar un mensaje")

        peticion.mensaje = request.POST["mensaje"]
        mensajes={}
        if request.POST["tipo_peticion"]==TIPO_PETICION_ANONIMO:
            mensajes["1"]=_("Te conozco desde hace tiempo y quiero conocerte mejor.")
            mensajes["2"]=_("Nos conocemos desde hace poco, pero no puedo olvidarte.")
            mensajes["3"]=_("Trabajamos juntos, tenemos muchas cosas en comun charlemos.")
            mensajes["4"]=_("Nuestras miradas se han encontrado, nuestras palabras tambien podrian.")
            mensajes["5"]=_("Estudiamos juntos, y desde que te vi no te olvido.")
        elif request.POST["tipo_peticion"]==TIPO_PETICION_CELESTINO:
            mensajes["1"]=_("Trabajo con vosotros y creo que deberiais conoceros mejor.")
            mensajes["2"]=_("Os he visto muchas veces, se que haceis buena pareja.")
            mensajes["3"]=_("Nos conocemos los tres y creo que os gustais.")
            mensajes["4"]=_("Os he visto a ambos en clase, creo que haceis buena pareja.")
        if request.POST.has_key("mensaje_anonimo"):
            peticion.mensaje_anonimo = mensajes[request.POST["mensaje_anonimo"]]

    if request.POST["tipo_peticion"]==TIPO_PETICION_CELESTINO:

        peticion.contacto2_nombre = request.POST["nombre2"]
        contacto2=""
        if request.POST["telefono2"]=="":
            try:
                validate_email(request.POST["email2"])
                contacto2 = request.POST["email2"]
            except ValidationError as e:
                errores.append(_("El email del segundo contacto es incorrecto"))
        else:
            if isTelefono(request.POST["telefono2"]):
                contacto2 = request.POST["telefono2"]
            else:
                errores.append(_("El telefono del segundo contacto no es valido"))
        if request.POST["pais2_id"]=="":
            datos["pais2_id"] = session["pais_id"]
        else:
            datos["pais2_id"] = int(request.POST["pais2_id"])

        pais = Paises.objects.get(id=datos["pais2_id"])
        peticion.contacto2_contacto = pais.codigo_pais+contacto2


        datos["telefono2"]=request.POST["telefono2"]
        datos["email2"]=request.POST["email2"]
        datos["nombre2"]=request.POST["nombre2"]
    if len(errores)==0:
        pais = Paises.objects.get(id=datos["pais_id"])
        peticion.telefono= peticion.telefono
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

@idioma()
@loginRequired()
def peticionEnviada(request):
    request.session["peticionEnviada"]=1
    peticion=Peticiones.objects.get(pk=request.session["peticionEnviada"])
    data = {"peticion":peticion}
    paginas={}
    paginas["1"]="anonimo"
    paginas["2"]="conecta"
    paginas["3"]="celestino"

    rendered = render_to_string("peticionEnviada.html",data)
    return base(request,rendered,paginas[peticion.tipo])

@idioma()
def rechazarContactoPeticion(request):
    usuario2=False
    lista_peticiones = Peticiones.objects.filter(codigo=request.GET["peticion"])
    if len(lista_peticiones)==0:
        usuario2=True
        lista_peticiones = Peticiones.objects.filter(codigo2=request.GET["peticion"])
    if len(lista_peticiones)>0:
        peticion = lista_peticiones[0]
        rechazo = Rechazos()
        if usuario2:
            rechazo.contacto = limpiaTelefono(peticion.contacto2_contacto)
        else:
            rechazo.contacto = limpiaTelefono(peticion.contacto_contacto)
        rechazo.usuario = peticion.usuario
        rechazo.general = False
        rechazo.save()
        enviaRechazo(rechazo)
        request.session["rechazoEnviado"]=rechazo.pk
        return HttpResponseRedirect('/rechazoEnviado')

    else:
        data = {}
        rendered = render_to_string("peticionNoExiste.html",data)
        return base(request,rendered,"peticion")

@idioma()
def rechazarZiipPeticion(request):
    usuario2=False
    lista_peticiones = Peticiones.objects.filter(codigo=request.GET["peticion"])
    if len(lista_peticiones)==0:
        usuario2=True
        lista_peticiones = Peticiones.objects.filter(codigo2=request.GET["peticion"])
    if len(lista_peticiones)>0:
        peticion = lista_peticiones[0]
        rechazo = Rechazos()
        if usuario2:
            rechazo.contacto = limpiaTelefono(peticion.contacto2_contacto)
        else:
            rechazo.contacto = limpiaTelefono(peticion.contacto_contacto)
        rechazo.usuario = None
        rechazo.general = True
        rechazo.save()
        enviaRechazo(rechazo)
        request.session["rechazoEnviado"]=rechazo.pk
        return HttpResponseRedirect('/rechazoEnviado')

    else:
        data = {}
        rendered = render_to_string("peticionNoExiste.html",data)
        return base(request,rendered,"rechazarPeticion")

@idioma()
def rechazoEnviado(request):
    mensajeRechazo=""
    if request.session.has_key("mensajeRechazo"):
        mensajeRechazo=request.session["mensajeRechazo"]

    csrf_token_value = get_token(request)
    data = {"csrf_token_value":csrf_token_value,"rechazoEnviado":request.session["rechazoEnviado"],"mensajeRechazo":mensajeRechazo}
    rendered = render_to_string("rechazoEnviado.html",data)
    return base(request,rendered,"peticion")

@idioma()
def aceptarRechazo(request):

    rechazo = Rechazos.objects.get(pk=request.POST["rechazoEnviado"])
    if rechazo.codigo == request.POST["codigo"]:
        rechazo.confirmado=True
        rechazo.save()
        return HttpResponseRedirect('/rechazoAceptado')
    else:
        request.session["mensajeRechazo"]=_("El codigo de rechazo es incorrecto")
        return HttpResponseRedirect('/rechazoEnviado')

@idioma()
def rechazoAceptado(request):

    csrf_token_value = get_token(request)
    data = {}
    rendered = render_to_string("rechazoAceptado.html",data)
    return base(request,rendered,"rechazarPeticion")

@idioma()
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

@idioma()
def contacto(request):
    mensaje=""
    if request.session.has_key("mensaje_contacto"):
        mensaje=request.session["mensaje_contacto"]
        request.session.pop("mensaje_contacto")
    csrf_token_value = get_token(request)
    data = {"csrf_token_value":csrf_token_value,"mensaje":mensaje}
    rendered = render_to_string("contacto.html",data)
    return base(request,rendered,"contacto")

def sendContacto(request):

    rendered="Mensaje enviado desde ziip<br>"
    rendered="Asunto:"+request.POST["asunto"]+"<br>"
    rendered="Email:"+request.POST["email"]+"<br>"
    rendered="Texto:"+request.POST["texto"]+"<br>"

    asunto="Contacto desde ziip"
    enviaMail.apply_async(args=[settings.MAIL_TO,asunto,rendered], queue=QUEUE_DEFAULT)

    request.session["mensaje_contacto"]=_("Mensaje enviado correctamente")
    return HttpResponseRedirect('/contacto')

@idioma()
def legal(request):
    texto = Textos.objects.get()
    data={"texto":texto.aviso_legal,"titulo":_("Aviso Legal")}
    rendered = render_to_string("textos.html",data)
    return base(request,rendered,"legal")

@idioma()
def privacidad(request):
    texto = Textos.objects.get()
    data={"texto":texto.privacidad,"titulo":_("Politica de privacidad")}
    rendered = render_to_string("textos.html",data)
    return base(request,rendered,"privacidad")


@idioma()
@loginRequired()
def recordarPassword(request):
    csrf_token_value = get_token(request)
    data={"csrf_token_value":csrf_token_value}
    rendered = render_to_string("recordarPassword.html",data)
    return base(request,rendered,"login")

@loginRequired()
def doRecordarPassword(request):
    usuario = Usuarios.objects.filter(pk=request.session["user_id"])
    usuario.password = generaPassword()
    usuario.save()

    data = { "usuario":usuario}
    rendered = render_to_string("mails/recordar.html", data)
    asunto = _("Recuperar password ziip")
    enviaMail.apply_async(args=[usuario.email,asunto,rendered], queue=QUEUE_DEFAULT)
    return redirect('/login')


def blog(request):
    data={}
    rendered = render_to_string("blog.html",data)
    return base(request,rendered,"blog")
