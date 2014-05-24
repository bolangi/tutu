#!/usr/bin/env perl
BEGIN { push @ARGV, qw(--environment=development) }
use Modern::Perl;
use Dancer;
load_app 'Tutu';
$Tutu::webmaster_name = qq($WEBMASTER_NAME);
$Tutu::webmaster_mail_address = qq($WEBMASTER_MAIL_ADDRESS);
$Tutu::website_url = qq($WEBSITE_URL);
$Tutu::website_name = qq($WEBSITE_NAME);
dance;
