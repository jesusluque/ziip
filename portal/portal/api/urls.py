from django.conf.urls import patterns, include, url

urlpatterns = patterns('',
    url(r'^test$', 'portal.api.views.test'),
    url(r'^solicitudAlta$', 'portal.api.views.solicitudAlta'),
    url(r'^confirmacionAlta$', 'portal.api.views.confirmacionAlta'),
    url(r'^solicitudBang$', 'portal.api.views.solicitudBang'),
    
}