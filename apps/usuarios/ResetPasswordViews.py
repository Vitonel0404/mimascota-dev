from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
import smtplib
import uuid
from django.http import HttpResponseRedirect
from django.shortcuts import redirect, render
from django.urls import reverse_lazy
from django.views.generic import FormView
from django.template.loader import render_to_string
from .formResetPassword import *
from veterinaria.settings import base,production

class ResetPasswordView(FormView):
    # TODO: Define form fields here
    form_class=ResetPasswordForm
    template_name='ResetPassword/password_reset_form.html'
    success_url=reverse_lazy('password_reset_done')

    def dispatch(self, request, *args, **kwargs):
        return super().dispatch(request, *args, **kwargs)
    
    def send_email_reset_password(self, user):
        data={}
        try:
            
            URL= base.DOMAIN if not production.DEBUG else self.request.META['HTTP_HOST']

            user.token=uuid.uuid4()
            user.save()

            mailServer =smtplib.SMTP(base.EMAIL_HOST, base.EMAIL_PORT)
            mailServer.ehlo()
            mailServer.starttls()
            mailServer.ehlo()
            mailServer.login(base.EMAIL_HOST_USER_VETTYPET, base.EMAIL_HOST_PASSWORD_VETTYPET)

            email_to=user.email
            mensaje=MIMEMultipart()
            mensaje['From']=base.EMAIL_HOST_USER_VETTYPET
            mensaje['To']=email_to
            mensaje['Subject']="Reestrablecimiento de contraseña"

            content=render_to_string('ResetPassword/send_email.html',{   
                'user':user,
                'link_resetpwd':'http://{}/usuarios/change_password/{}/'.format(URL,str(user.token)),
                'link_home':'http://{}'.format(URL)
            })
            mensaje.attach(MIMEText(content, 'html'))

            mailServer.sendmail(base.EMAIL_HOST_USER_VETTYPET,
                        email_to,
                        mensaje.as_string())
        except Exception as e:
            data['error']=str(e)

        return data


    def post(self, request, *args,**kwargs):
        data={}
        try:
            form= ResetPasswordForm(request.POST)
            if form.is_valid():
                user = form.get_user()
                data=self.send_email_reset_password(user)
                return render(request,'ResetPassword/password_reset_done.html',data)
            else:
                data['error']=form.errors
                data['form']=form
            return render(request,'ResetPassword/password_reset_form.html',data)
        except Exception as e:
            data['error']=str(e)

        

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['title']= 'Reestablecimiento de Contraseña'
        return context

class ChangePasswordView(FormView):
    form_class=ChangePasswordForm
    template_name='ResetPassword/password_reset_confirm.html'
    success_url=reverse_lazy('dashboard')

    def dispatch(self, request, *args, **kwargs):
        return super().dispatch(request, *args, **kwargs)

    def get(self, request, *args, **kwargs):
        token =self.kwargs['token']
        if Usuario.objects.filter(token=token).exists():
            return super().get(request, *args, **kwargs)
        return HttpResponseRedirect(self.success_url)
        
    def post(self, request, *args,**kwargs):
        data={}
        try:
            form= ChangePasswordForm(request.POST)
            if form.is_valid():
                user=Usuario.objects.get(token=self.kwargs['token'])
                user.set_password(request.POST['password'])
                user.token=uuid.uuid4()
                user.save()
                return redirect(to='dashboard')
            else:
                data['error']=form.errors
                data['form']=form
            return render(request,'ResetPassword/password_reset_confirm.html',data)
        except Exception as e:
            data['error']=str(e)
        

    def get_context_data(self, **kwargs):
        context=super().get_context_data(**kwargs)
        context['title']='Reseteo de Contraseña'
        return context