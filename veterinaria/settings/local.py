from .base import *
DEBUG = True

ALLOWED_HOSTS = ['*']

# Database
# https://docs.djangoproject.com/en/3.2/ref/settings/#databases

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql_psycopg2',
        'NAME': 'vettypet-dev',
        'USER': 'postgres',
        'PASSWORD': 'postgres',
        'HOST':'localhost',
        'DATABASE_PORT':'5432',
    }
}

STATICFILES_DIRS=[os.path.join(BASE_DIR, 'static'),'veterinaria/static',]