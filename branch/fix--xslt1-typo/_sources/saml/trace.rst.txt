Making a SAML trace
===================

Before you can connect a production SP, ITS IAM will require you to connect an
acceptation SP first to test if it works. They'll also want a SAML
trace log from a successful login/logout using the acceptation IdP.

This can be done by using the SAML-tracer extension:
`Firefox <https://addons.mozilla.org/en-US/firefox/addon/saml-tracer/>`_,
`Chrome <https://chrome.google.com/webstore/detail/saml-tracer/mpdajninpobndbfcldcmbpnnbhibjmch?hl=en>`_

ITS IAM expects three things in the trace:

  * A successful login
  * A successful SP-initiated logout
  * A successful IdP-initiated logout

See also the IAM wiki for more info:
`SAML-tracer <https://wiki.iam.uu.nl/books/saml-tracer>`_

Quick tracer-guide
------------------

(Note: this is a very simple explanation to get you started, and is in no way
a proper user-guide).

The tracer will list all requests done by your browser. Any requests that handle
SAML requests will be labeled 'SAML'. If you click on said request, the details
view will also have the 'SAML' and 'Summary' tabs.

The SAML tab will show you the raw SAML request, the 'Summary' will show a human
readable version of the request.

All SAML requests should contain a 'Status' element (which is not displayed in
the summary, sadly). You want them all to look like this:

.. code-block:: xml

    <ns0:Status>
        <ns0:StatusCode Value="urn:oasis:names:tc:SAML:2.0:status:Success" />
    </ns0:Status>

Note: namespaces (ns0 in this example) might vary.

Steps
-----

1. Open the SAML tracer extension

   - Preferably in a private window of a browser with no other windows open.
     (The tracer extension captures all traffic, so this is to keep the log
     clean)

2. Log in with SAML in your app (using one of your ITS test accounts)

3. Log out using your app's saml-logout page

   - If you're nice, you can export the trace now (see step 7) and rename that
     file 'SP initiated logout' and clear the log. Then export the next steps
     as 'IdP initiated logout'.

     IAM can handle a combined trace file, but it's clearer if they are in
     separate files.

4. Log in again

5. Go to https://login.acc.uu.nl/nidp/app/logout

6. You'll see an error page, most likely. This probably does not actually mean
   your logout didn't work. Check the SAML LogoutResponse (should be the last one
   labeled SAML) in the tracer to see if the actual response says 'Success'.

7. If everything checks out, press the export button, keep the default export
   settings and press 'export'. This will download a JSON file, which you can
   send to ITS IAM.


