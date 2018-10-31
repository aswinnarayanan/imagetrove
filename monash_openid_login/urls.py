from django.conf.urls import url

from . import views


urlpatterns = [
    url(r'^login/$', views.LoginView.as_view(),
        name='tardis.apps.monash.views.migrate_accounts'),
]
