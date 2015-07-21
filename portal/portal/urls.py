from django.conf.urls import patterns, include, url
from django.conf.urls.static import static
from django.contrib import admin
from portal.settings import BASE_DIR
admin.autodiscover()

urlpatterns = patterns('',
    # Examples:
    # url(r'^$', 'portal.views.home', name='home'),
    # url(r'^blog/', include('blog.urls')),
    url(r'^grappelli/', include('grappelli.urls')), # grappelli URLS
    url(r'^admin/', include(admin.site.urls)),
    url(r'^api/', include('portal.api.urls')),
    url(r'^', include('portal.web.urls')),



)+ (
        static('uploads', document_root=BASE_DIR+"/portal/uploads", show_indexes=True)+
        static('css', document_root=BASE_DIR+"/portal/media/css", show_indexes=True)+
        static('js', document_root=BASE_DIR+"/portal/media/js", show_indexes=True)+
        static('img', document_root=BASE_DIR+"/portal/media/img", show_indexes=True)
    )
