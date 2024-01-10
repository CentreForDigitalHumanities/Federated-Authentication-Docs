Development IdP
===============

To help implementing SAML in CDH applications, a development Identity Provider
is available as a local testing target during implementation. It can emulate
the UU IdP as well as SurfConext.

The app is available `on the CDH GitHub <https://github.com/CentreForDigitalHumanities/Development-IdP>`_.
Please refer to the README for setup. The interface itself should be
self-explaining; if anything is unclear, please open an issue!

Hosted test IdP
---------------

This IdP is also deployed on a CDH server, to test the deployment of SAML-enabled
apps before testing said app with the UU (acceptation) IdP/SurfConext.

It can also be used for non-acceptation deployments (e.g. test/dev), for quickly
testing new SAML configurations or having more control over test accounts.

Please ask around for details regarding the location and credentials.

.. warning::

    Just like the local variant, the hosted test IdP is not considered secure
    in any way. Thus, you should only connect deployed apps not containing
    *anything* sensitive.

    As it's meant for testing non-production apps, this should already be the
    case per UU information security practices. Thus, this warning is also
    a reminder to follow those practices.