Django guide
============

These instructions use the CDH Federated Auth django app (FA-app), part of the
`Django Shared Core <https://github.com/CentreForDigitalHumanities/django-shared-core>`_
(DSC) project.

This app simplifies setting up SAML in Django, and uses DjangoSaml2 and PySAML2
libraries under the hood.

.. contents:: **Table of Contents**
    :local:
    :depth: 3

Library Setup
-------------

Dependencies
************

1. Depending on which configuration you use, any of these Linux packages may be
   required:

   * libxml2
   * libxml2-dev
   * libxslt1-dev
   * python-dev
   * pkg-config
   * xmlsec1

2. For the python side, you only need to include the DSC library to your
   dependency list:

   .. code-block::

      cdh-django-core[federated-auth] @ git+https://github.com/CentreForDigitalHumanities/django-shared-core.git@<version>

   This will pull in all required dependencies. Substitute ``<version>`` with
   the latest release tag.

   .. note::
      If you use other apps of the DSC project, you should add ``federated-auth``
      to the existing list of optional dependencies.

Django configuration
********************

For this guide, we will be adding SAML support in such a way that it can either
run without or with SAML (as default). However, we will also provide some notes
on how to add SAML support as an additional authentication backend.

1. Create a new file ``saml_settings.py`` next to the project's ``settings.py``,
   and add the following code:

   .. code-block:: python

        from django.urls import reverse_lazy
        from os import path
        from cdh.federated_auth.saml.settings import *

        _BASE_DIR = path.dirname(os.path.dirname(__file__))

        SAML_CONFIG = create_saml_config(
            base_url='<app_hostname>',
            name='<app_name>',
            key_file=path.join(_BASE_DIR, 'certs/private.key'),
            cert_file=path.join(_BASE_DIR, 'certs/public.cert'),
            idp_metadata='https://login.uu.nl/nidp/saml2/metadata',
            contact_given_name='<contact_name>',
            contact_email='<contact_email>',
        )

        AUTHENTICATION_BACKENDS = (
            'django.contrib.auth.backends.ModelBackend',
            'djangosaml2.backends.Saml2Backend',
        )

        LOGIN_URL = reverse_lazy('saml2_login')


   Change the following values:

   * ``<app_hostname>``: the hostname of the app, **including** ``https://``
   * ``<app_name>``: the name of your application
   * ``<contact_name>``: the name of the team managing this application
   * ``<contact_email>``: the email address of the team managing this
     application. ITS will use this email address as a contact when they
     make changes to the IdP that requires changes on the SP as well.
   * ``AUTHENTICATION_BACKENDS``: if you want to keep using other authentication
     backends, you'll need to add those here as well.
   * ``LOGIN_URL``: This will make SAML the default page when Django redirects
     the user trying to access a login-required page. If you want to use
     multiple login backends, you should omit this setting and provide a link
     to this view on your regular login page instead.

2. These settings are for the production IdP. To use the acceptation IdP,
   change ``login.uu.nl`` to ``login.acc.uu.nl`` (in ``idp_metadata``). You can
   also use the URL of the :doc:`Development IdP <../developmentidp/index>`
   here, if you are using that.

3. (Optional) These settings assume you use the default Django user model and
   corresponding SAML user attributes. If you use a different user model/more
   attributes, you need to add a custom *attribute mapping*. To do this, add
   the following to ``saml_settings.py``:

   .. code-block:: python

        SAML_ATTRIBUTE_MAPPING = {
            'uuShortID':  ('username',),
            'mail':     ('email',),
            'givenName': ('first_name',),
            'uuPrefixedSn':  ('last_name',),
        }

   Add/change the attributes you use here. The key of this dict represents the
   name of the SAML attribute (the name you get in the response from the IdP),
   the value represents the name of the attribute in the Django user model.

   .. note::

      SurfConext uses different attribute names, which can be found
      `on their wiki <https://wiki.surfnet.nl/display/surfconextdev/Attributes+in+SURFconext>`_.

      The following is an attribute map for the default Django user model, using
      SurfConext attribute names:


      .. code-block:: python

            SAML_ATTRIBUTE_MAPPING = {
                'uid':  ('username',),
                'mail':     ('email',),
                'givenName': ('first_name',),
                'sn':  ('last_name',),
            }


4. In your project's root *urlconf*, add the following:

   .. code-block:: python

        from django.conf import settings

        # [..] (your urlpatterns, etc)

        if hasattr(settings, 'SAML_CONFIG'):
            urlpatterns.append(
                path('saml/', include('djangosaml2.urls')),
            )

5. (Optional) If your app is going to use more than one authentication backend,
   you might have to use a different logout view. The default SAML logout view
   can only handle users logged in through SAML.

   You can use the default Django logout view alongside the SAML version, which
   has the drawback that you will have to manually route your users to the
   correct one.

   The FA-app provides a custom logout view that combines the default Django
   logout view with the SAML version. To use it, simply include the
   ``cdh.federated_auth.saml.views.LogoutInitView`` in your *urlconf* and
   direct your users to that view to log out.

6. In your project's ``settings.py``, add the following to the bottom of the file:

   .. code-block:: python

        try:
            from .saml_settings import *

            # Only add the required apps/middleware if we could load the SAML config
            INSTALLED_APPS += SAML_APPS
            MIDDLEWARE += SAML_MIDDLEWARE

        except ImportError:
            print('Proceeding without SAML')

   This requires that ``INSTALLED_APPS`` and ``MIDDLEWARE`` as lists, not tuples.

7. Create a folder called ``certs`` in the project root. This directory will
   contain your app's signing certificate. Please follow the
   :doc:`certificates guide <certificates>` to generate those. Make sure they
   the private key and certificate are called ``private.key`` and ``public.cert``
   respectively. (Or update the filenames in ``saml_settings.py`` to the
   correct names).

   .. warning::
      It is generally a very bad idea to store the certificates you use on
      deployed systems in git. However, you can store 'development-only' certs,
      and replace them manually during deployment on the server.

8. Double check that you are using the correct login/logout views everywhere in
   your app.

9. (Optional, but recommended). Test your configuration using the
   :doc:`Development IdP <../developmentidp/index>`

Contact ITS
-----------

You should now contact ITS and ask them to add your Service Provider to their
Identity Provider. Save the metadata (``<app_hostname>/saml/metadata/``) as an
XML file and send this file to ITS, along with the message that you want to
register your application with their Identity Provider. Give the base URL of your
application and say if you want to make use of their acceptation or production
Identity Provider (depending on what URL you entered in the ``saml_settings.py``
file).

Also indicate which fields you want the Identity Provider to pass back with a
successful authentication redirect (such as solis-ID, full name, e-mail address,
etc).

Once they have added you, you should be able to use SAML for authenticating your
users.

.. note::

   ITS requires SAML trace of a successful login/logout on the acceptation
   environment before they allow a production SP to be added to the IdP.
   Please see the :doc:`SAML trace page <trace>` for more info.

Tips
----

Example config file
*******************

In the guide we created a ``saml_settings.py`` to store all the required SAML
configuration. As these settings vary between deployments (production,
acceptation, (local) development), it is a good idea to put this file in
your *gitignore*, and provide an 'example file' in your git repo instead.
(``saml_settings.example.py`` for example).

As we configured Django to only add all the SAML related urls etc if the
``saml_settings.py`` file is present, this will also enable local development
using the default authentication backend only.

Multiple IdP's
**************

The FA-app is meant to be used with one IdP only. However, if you have multiple
IdP which use the same config, you can use them simultaneously by adding the
following config override to ``create_saml_config``:

.. code-block:: python

    config_overrides={
        'metadata': {
            'remote': [
                {'url': '<idp1_metadata_url>',},
                {'url': '<idp2_metadata_url>',},
            ]
        }
    }

This can be used to in non-production environments to add both the ITS
acceptation IdP and the :doc:`Development IdP <../developmentidp/index>`
as a fallback option. (Useful if you want to be able to properly test SAML in
the acceptation but also want to use custom test users).

When logging in, you will be prompted for which IdP you want to use.

If you want to use multiple IdP's that use different configurations, please open
an issue in the DSC repository.

Advanced options
****************

This guide is meant to easily setup SAML for 90% of the use-cases, for
developers unfamiliar with SAML. Thus, it does not fully explain all available
(configuration) options.

If you have a special edge case or other requirements that require special
configuration, it is recommended you consult the
``cdh.federated_auth.saml.settings`` file for more in-depth documentation.
