Tutu
====

Flat-file CMS

Tutu is a flat-file CMS for creating dynamic websites.

You can develop and test the site on your own system, and
update the production site using Tutu's rsync script.

Pages are created as text files, typically formatted with
Markdown. Authenticated users may access pages and upload
and download files based on per-user permissions.
 
Tutu is inspired by Blosxom and based on the Dancer web
framework.

INSTALLATION
------------

To install this module, you may run the following commands:

	perl Makefile.PL
	make
	make test
	make install

INITIAL TESTING (no configuration needed)
-----------------------------------------

	cd $TUTU_BUILD_DIRECTORY
    cd webapp
	./dance.psgi #  point your browser to http://localhost:3000
	
CREATING A NEW SITE (WEBAPP)
----------------------------

	Edit WEBSITE-CONFIG to suit your planned site.
	Run this script:

    tutu-genapp WEBSITE-CONFIG

    Move the $WEBSITE_ROOT and $WEBSITE_DOMAIN directories
    to the appropriate locations, if desired.

	cd $WEBSITE_ROOT

	./dance.psgi # point your browser to http://localhost:3000

UTILITIES
---------
Run **tutu-genapp** in your Tutu build directory
to create webapp and domain directories
for a new website, based on a config file.

Run **tutu-index** in your webapp directory to 
create directory listings for your /public directory.

Run **tutu-pass** in your webapp directory to create the
passwd file that you website will need to verify logins.
This script takes the file **pass** as input.

Run **tutu-sync** in your webapp directory to
copy files to the remote server.

COPYRIGHT AND LICENCE
---------------------

Copyright (C) 2014 Joel Roth

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
