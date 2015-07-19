from django import template
from django.template.defaultfilters import stringfilter

register = template.Library()

@register.filter
@stringfilter
def imagenTipo(value):
    imagenes={}
    imagenes["1"]="jicanonimoA.png"
    imagenes["2"]="jicconectaA.png"
    imagenes["3"]="jiccelestinaA.png"
    return "<img src='/img/"+imagenes[value]+"'  style='width: 100px;'>"
