# CDH Federated Authentication Documentation
This repo tries to describe the process of setting up Federated Authentication
to talk to the Identity Provider of University Utrechts ITS and/or SurfConext. 
Currently it documents SAML authentication, with OpenID to be added in the future.

The intention of this project is to use the community to add documentation and
example implementations for many more languages, which will be an ongoing 
project.

The documentation is best viewed at https://centrefordigitalhumanities.github.io/Federated-Authentication-Docs/;
Alternatively you can view the RST files through GitHub itself, or as 
plain text files on your computer. (Do note that GitHub will error on sphinx 
specific RST).

Do you see room for improvement in the existing documentation? Or have you used
this how-to to use a library for another language? **Then join the cause!**.
Clone this repository and add documentation and minimal sample code for the
library you used. Or just suggest changes that you think make the existing
work better. Then send in a pull request with your changes.

## Authoring

Note: we assume you are using either Linux or MacOS. 

The documentation is written in Sphinx flavoured ReStructured Text (rst). 
If you are unfamiliar, you can check out [this page](https://sphinx-intro-tutorial.readthedocs.io/en/latest/rst_intro.html)
for an introduction.

Once you've done so (or are already familiar), just start editting the RST files!

To update the HTML export you'll need Python 3 and pip. It's recommended to use
a virtual environment to install the dependencies. 

Install the dependencies in ``requirements.txt`` with pip, and you'll be ready 
to go. Just run ``make html`` to regenerate the HTML files.
