from django.template.loader import render_to_string
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
import smtplib

from veterinariaOlmos.settings import base
# Create your tests here.
def send_email2():
    try:
        mailServer =smtplib.SMTP(base.EMAIL_HOST, base.EMAIL_PORT)
        print(mailServer.ehlo())
        mailServer.starttls()
        print(mailServer.ehlo())
        mailServer.login(base.EMAIL_HOST_USER, base.EMAIL_HOST_PASSWORD)
        print('conectado..')

        email_to='victor0404.vmhm@gmail.com'
        #Construimos el mensaje simple
        mensaje=MIMEMultipart()
        mensaje['From']=base.EMAIL_HOST_USER
        mensaje['To']=email_to
        mensaje['Subject']="Tienes un correo"

        content=render_to_string('Email/email2.html',{'user':'Victor0404'})

        mensaje.attach(MIMEText(content, 'html'))

        mailServer.sendmail(base.EMAIL_HOST_USER,
                    email_to,
                    mensaje.as_string())
        print("Metodo 2 de envio de correo exitoso!")
    except Exception as e:
        print(e)

