from django import forms

from .models import Usuario

class ResetPasswordForm(forms.Form):
    """ResetPasswordForm definition."""

    # TODO: Define form fields here
    username= forms.CharField(widget=forms.TextInput(attrs={
        'placeholder':'Ingrese un usuario',
        'class':'form-control form-control-user',
        'autocomplete':'off'
    }))

    def clean(self):
        cleaned=super().clean()
        if not Usuario.objects.filter(username=cleaned['username']).exists():
            raise forms.ValidationError('El usuario no existe')
        return cleaned
    
    def get_user(self):
        username=self.cleaned_data.get('username')
        return Usuario.objects.get(username=username)

class ChangePasswordForm(forms.Form):
    password= forms.CharField(widget=forms.PasswordInput(attrs={
        'placeholder':'Ingrese una contraseña nueva',
        'class':'form-control form-control-user',
        'autocomplete':'off'
    }))
    confirm_password= forms.CharField(widget=forms.PasswordInput(attrs={
        'placeholder':'Repita la contraseña',
        'class':'form-control form-control-user',
        'autocomplete':'off'
    }))

    def clean(self):
        cleaned=super().clean()
        password=cleaned['password']
        confirm_password=cleaned['confirm_password']
        if password != confirm_password:
            raise forms.ValidationError('Las contraseñas no coinciden. Asegurese de escribir correctamente')
        return cleaned