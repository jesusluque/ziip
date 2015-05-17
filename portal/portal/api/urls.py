from django.conf.urls import patterns, include, url

urlpatterns = patterns('',
    url(r'^test$', 'portal.api.views.test'),
    url(r'^login$', 'portal.api.views.login'),
    url(r'^alta$', 'portal.api.views.alta'),
    url(r'^confirmacionMovil$', 'portal.api.views.confirmacionMovil'),
     
    
    
    
    
    #url(r'^solicitudAlta$', 'portal.api.views.solicitudAlta'),
    #url(r'^confirmacionAlta$', 'portal.api.views.confirmacionAlta'),
    #url(r'^solicitudBang$', 'portal.api.views.solicitudBang'),
    
)