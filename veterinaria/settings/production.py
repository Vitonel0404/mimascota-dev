from .base import *

DEBUG = True

ALLOWED_HOSTS = ['*']

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql_psycopg2',
        'NAME': 'vettypet',
        'USER':'postgres',
        'PASSWORD':'ydaleu',
        'HOST':'159.223.186.222',
        'PORT':5432,
    }
}

STATICFILES_DIRS=(BASE_DIR, 'static')