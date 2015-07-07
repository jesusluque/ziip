from django.conf.urls import patterns, include, url
from django.conf.urls.static import static
from django.contrib import admin
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
        static('uploads', document_root="/Users/marodriguez/git/ziip/portal/portal/uploads", show_indexes=True)+
        #casa

        #static('css', document_root="/Users/marodriguez/git/ziip/portal/portal/media/css", show_indexes=True)+
        #static('js', document_root="/Users/marodriguez/git/ziip/portal/portal/media/js", show_indexes=True)+
        #static('img', document_root="/Users/marodriguez/git/ziip/portal/portal/media/img", show_indexes=True)+

        #Oficina
        static('css', document_root="/Users/manuthema/personal/ziip/portal/portal/media/css", show_indexes=True)+
        static('js', document_root="/Users/manuthema/personal/ziip/portal/portal/media/js", show_indexes=True)+
        static('img', document_root="/Users/manuthema/personal/ziip/portal/portal/media/img", show_indexes=True)
    )
