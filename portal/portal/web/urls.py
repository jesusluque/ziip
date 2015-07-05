from django.conf.urls import patterns, include, url

urlpatterns = patterns('',
    url(r'^$', 'portal.web.views.home'),
    url(r'^login$', 'portal.web.views.login'),
    url(r'^alta$', 'portal.web.views.alta'),
    
)