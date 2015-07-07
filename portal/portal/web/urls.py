from django.conf.urls import patterns, include, url

urlpatterns = patterns('',
    url(r'^$', 'portal.web.views.index'),
    url(r'^login$', 'portal.web.views.login'),
    url(r'^doLogin$', 'portal.web.views.doLogin'),
    url(r'^home$', 'portal.web.views.home'),
    url(r'^registro$', 'portal.web.views.registro'),


    url(r'^legal$', 'portal.web.views.legal'),
    url(r'^privacidad$', 'portal.web.views.privacidad'),
)
