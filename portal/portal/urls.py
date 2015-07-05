from django.conf.urls import patterns, include, url
from django.conf.urls.static import static
from django.contrib import admin
admin.autodiscover()

urlpatterns = patterns('',
    # Examples:
    # url(r'^$', 'portal.views.home', name='home'),
    # url(r'^blog/', include('blog.urls')),

    url(r'^admin/', include(admin.site.urls)),
    url(r'^api/', include('portal.api.urls')),
    url(r'^', include('portal.web.urls')),
    
    
    
)+ (
        static('uploads', document_root="/Users/marodriguez/git/ziip/portal/portal/uploads", show_indexes=True)
    )
