#!/usr/bin/env perl
BEGIN { push @ARGV, qw(--environment=development) }
use Modern::Perl;
use Dancer;
load_app 'Tutu';
dance;
