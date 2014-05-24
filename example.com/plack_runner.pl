#!/usr/bin/perl
use strict;
use Plack::Runner;
Plack::Runner->run("$WEBROOT/dance.psgi");
