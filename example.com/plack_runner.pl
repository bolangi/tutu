#!/usr/bin/perl
use strict;
use Plack::Runner;
Plack::Runner->run("$WEBSITE_ROOT/dance.psgi");
