from django import template
from django.template.defaultfilters import stringfilter

register = template.Library()

@register.filter
@stringfilter
def imagenTipo(value):
    imagenes={}
    imagenes["1"]="anonimo.png"
    imagenes["2"]="conecta.png"
    imagenes["3"]="celestina.png"
    return "<img src='/img/"+imagenes[value]+"'>"
