from django.contrib import admin
from portal.core.models import *


class TinyAdmin(admin.ModelAdmin):
    class Media:
        js = ['/static/grappelli/tinymce/jscripts/tiny_mce/tiny_mce.js','/static/grappelli/tinymce_setup/tinymce_setup.js']




class TextosAdmin(TinyAdmin):
#Para no dejar crear nuevos registros
    def has_add_permission(self, request):
        return False
#PAra que no se pueda borrar un tipo de datos
    def get_actions(self,request):
       return []


admin.site.register(Textos, TextosAdmin)
admin.site.register(Paises)
