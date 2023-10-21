from django.shortcuts import redirect, render

class UsuarioStaffMixin(object):
    def dispatch(self, request, *args, **kwargs):
        if request.user.is_authenticated:
            if request.user.is_staff:
                return super().dispatch(request, *args, **kwargs)
        return redirect('index')

class UsuarioVendedorMixin(object):
    def dispatch(self, request, *args, **kwargs):
        if request.user.is_authenticated:
            if  request.user.is_staff or request.user.id_tipo_usuario==3:
                return super().dispatch(request, *args, **kwargs)
        return redirect('index')

class UsuarioCompradorMixin(object):
    def dispatch(self, request, *args, **kwargs):
        if request.user.is_authenticated:
            if request.user.is_staff or request.user.id_tipo_usuario==5:
                return super().dispatch(request, *args, **kwargs)
        return redirect('index')