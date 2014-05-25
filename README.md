Tutu
====

Flat-file CMS based on the Dancer web framework

Tutu is a flat-file CMS inspired by Blosxom, a minimalist
blogging tool. Pages are created as text files, typically
formatted with Markdown.  Tutu is based on the Dancer web
framework.
   
Authenticated users may upload and download files.

Access to individual pages and directories may be given on a
per user basis.

INSTALLATION
------------

To install this module, you may run the following commands:

	perl Makefile.PL
	make
	make test
	make install

INITIAL TESTING
---------------

    cd webapp
	./dance.psgi #  point your browser to http://localhost:3000
	
CUSTOMIZING
-----------

	Edit MY_WEBSITE_INIT to suit your planned site.
	Run this script:

    ./customize.pl

	cd $WEBSITE_ROOT

	./dance.psgi # point your browser to http://localhost:3000

    Move the $WEBSITE_ROOT and $WEBSITE_DOMAIN directories
    to the appropriate locations, if desired.

UTILITIES
---------

Run **tutu-index** in your webapp directory to 
create directory listings for your /public directory.

Run **tutu-pass** in your webapp directory to create the
passwd file that you website will need to verify logins.
This script takes the file **pass** as input.


COPYRIGHT AND LICENCE
---------------------

Copyright (C) 2014 Joel Roth

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
