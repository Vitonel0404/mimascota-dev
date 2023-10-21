from django.urls import path
from django.contrib.auth import views as auth_views
from django.contrib.auth.decorators import login_required

from apps.usuarios.ResetPasswordViews import ChangePasswordView, ResetPasswordView
from .views import *

urlpatterns =[
    path('usuario/', login_required(UsuariosView.as_view()), name='usuario'),
    path('listar_usuario/', login_required(UsauarioListView.as_view()), name='listar_usuario'),
    path('modificar_usuario/<int:id_usuario>/', login_required(UsuarioUpdateView.as_view()), name='modificar_usuario'),
    path('eliminar_usuario/<int:id_usuario>/', login_required(UsuarioDeleteView.as_view()), name='eliminar_usuario'),
    path('listar_permisos_usuario/<int:id_usuario>/', login_required(PermissionUserListView.as_view()), name='listar_permisos_usuario'),
    path('asignar_permisos/<int:id_usuario>/', login_required(PermissionCreateView.as_view()), name='asignar_permisos'),
    path('listar_permisos/', login_required(PermissionListView.as_view()), name='listar_permisos'),

    path('reset_password/', ResetPasswordView.as_view(), name='reset_password'),
    path('change_password/<str:token>/', ChangePasswordView.as_view(), name='change_password'),
    path('reset/<uidb64>/<token>/', auth_views.PasswordResetConfirmView.as_view(template_name='ResetPassword/password_reset_confirm.html'), name='password_reset_confirm'),
    path('reset_password_complete/', auth_views.PasswordResetCompleteView.as_view(template_name='ResetPassword/password_reset_complete.html'), name='password_reset_complete'),
]