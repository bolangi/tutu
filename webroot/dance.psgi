#!/usr/bin/env perl
BEGIN { push @ARGV, qw(--environment=development) }
use Modern::Perl;
use Dancer;
load_app 'Tutu';
$Tutu::webmaster_name = $WEBMASTER_NAME;
$Tutu::webmaster_mail_address = $WEBMASTER_MAIL_ADDRESS;
$Tutu::website_url = $WEBSITE_URL;
$Tutu::website_name = $WEBSITE_NAME;
dance;
