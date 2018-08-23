from default_settings import *

# Add site specific changes here.

# Turn on django debug mode.
DEBUG = True

# Use the built-in SQLite database for testing.
# The database needs to be named something other than "tardis" to avoid
# a conflict with a directory of the same name.
DATABASES['default']['ENGINE'] = 'django.db.backends.postgresql_psycopg2'
DATABASES['default']['NAME'] = 'tardis'
DATABASES['default']['USER'] = 'admin'
DATABASES['default']['PASSWORD'] = 'admin_CHANGEME'
DATABASES['default']['HOST'] = '127.0.0.1'
DATABASES['default']['PORT'] = ''

# INSTALLED_APPS += ('longerusernameandemail','south')

# execute this wonderful command to have your settings.py created/updated
# with a generated Django SECRET_KEY (required for MyTardis to run)
# python -c "import os; from random import choice; key_line = '%sSECRET_KEY=\"%s\"  # generated from build.sh\n' % ('from tardisdefault_settings import * \n\n' if not os.path.isfile('settings.py') else '', ''.join([choice('abcdefghijklmnopqrstuvwxyz0123456789@#$^&*(-_=+)') for i in range(50)])); f=open('settings.py', 'a+'); f.write(key_line); f.close()"
