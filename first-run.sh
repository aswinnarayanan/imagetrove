
source ~/appenv/bin/activate; python mytardis.py createcachetable default_cache
source ~/appenv/bin/activate; python mytardis.py createcachetable celery_lock_cache
source ~/appenv/bin/activate; python mytardis.py makemigrations --noinput
source ~/appenv/bin/activate; python mytardis.py migrate --noinput
# source ~/appenv/bin/activate; python mytardis.py collectstatic
source ~/appenv/bin/activate; python mytardis.py rebuild_index