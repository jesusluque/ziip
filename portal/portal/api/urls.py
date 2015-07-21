from django.conf.urls import patterns, include, url

urlpatterns = patterns('',
    #url(r'^test$', 'portal.api.views.test'),
    url(r'^login$', 'portal.api.views.login'),
    url(r'^alta$', 'portal.api.views.alta'),
    url(r'^confirmacionMovil$', 'portal.api.views.confirmacionMovil'),
    url(r'^editaMovil$', 'portal.api.views.editaMovil'),
    url(r'^editaImagen$', 'portal.api.views.editaImagen'),

    url(r'^sendMensajeAnonimo$', 'portal.api.views.sendMensajeAnonimo'),
    url(r'^sendConecta$', 'portal.api.views.sendConecta'),
    url(r'^sendCelestino$', 'portal.api.views.sendCelestino'),
    url(r'^getContactos$', 'portal.api.views.getContactos'),
    url(r'^getRecientes$', 'portal.api.views.getRecientes'),






    #url(r'^solicitudAlta$', 'portal.api.views.solicitudAlta'),
    #url(r'^confirmacionAlta$', 'portal.api.views.confirmacionAlta'),
    #url(r'^solicitudBang$', 'portal.api.views.solicitudBang'),

)
