from social_core.exceptions import AuthFailed


def create_google_user(strategy, details, backend, user=None, *args, **kwargs):
    """
    Override social_auth's create_user method so we can prevent Monash users
    from creating Store.Monash accounts via Google
    """
    from social_core.pipeline.user import create_user

    if 'monash.edu' not in details['email']:
        return create_user(strategy, details, backend, user, *args, **kwargs)
    raise AuthFailed(backend, "Monash users should log in using the Australian Access Federation instead of Google.")
