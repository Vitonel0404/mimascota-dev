from django.shortcuts import redirect, render
from django.urls import reverse
from apps.empresa.views import globales
from .models import Empresa

class ValidatedStatusEmpresaMixin(object):
    def dispatch(self, request, *args, **kwargs):
        if request.user.is_authenticated:
            id_empresa=globales(request)['id_empresa']
            status = Empresa.objects.filter(id=id_empresa).values('estado_pago','estado')
            for s in status:
                if s['estado'] == False:
                    return redirect('logout')
                if s['estado_pago'] == False:
                    return render(request,'pagopendiente.html')
                return super().dispatch(request, *args, **kwargs)