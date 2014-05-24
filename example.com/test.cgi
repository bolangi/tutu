#!/usr/bin/env perl
use strict;
print "Content-type: text/html\n\n";
print <<HTML;
<html><body><h1>It works!</h1>
<p>
<p>This is the default web page for this server.</p>
<p>The web server software is running but no content has been added, yet.</p>
HTML

while(my ($k,$v) = each %ENV){
  print "$k<br />  $v<p>";
}
print $/;
print <<HTML;
</body></html>
HTML
