from django.conf.urls import patterns, include, url

urlpatterns = patterns('',
    url(r'^$', 'portal.web.views.index'),
    url(r'^login$', 'portal.web.views.login'),
    url(r'^doLogin$', 'portal.web.views.doLogin'),
    url(r'^home$', 'portal.web.views.home'),
    url(r'^registro$', 'portal.web.views.registro'),
    url(r'^doAlta$', 'portal.web.views.doAlta'),
    url(r'^confirmaMovil$', 'portal.web.views.confirmaMovil'),
    url(r'^doConfirmaMovil$', 'portal.web.views.doConfirmaMovil'),
    url(r'^peticionPrivado$', 'portal.web.views.peticionPrivado'),
    url(r'^aceptarContactoPeticion$', 'portal.web.views.aceptarContactoPeticion'),
    url(r'^contactos$', 'portal.web.views.contactos'),
    url(r'^recientes$', 'portal.web.views.recientes'),
    url(r'^ziip$', 'portal.web.views.ziip'),
    url(r'^ajustes$', 'portal.web.views.ajustes'),
    url(r'^saveAjustes$', 'portal.web.views.saveAjustes'),
    url(r'^conecta$', 'portal.web.views.conecta'),
    url(r'^anonimo$', 'portal.web.views.anonimo'),
    url(r'^celestino$', 'portal.web.views.celestino'),
    url(r'^sendPeticion$', 'portal.web.views.sendPeticion'),
    url(r'^peticionEnviada$', 'portal.web.views.peticionEnviada'),
    url(r'^chat$', 'portal.web.views.chat'),

    url(r'^logout$', 'portal.web.views.logout'),
    url(r'^legal$', 'portal.web.views.legal'),
    url(r'^privacidad$', 'portal.web.views.privacidad'),


    url(r'^(?P<codigo>\w{9})$', 'portal.web.views.peticion'),

)
