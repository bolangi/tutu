#!/usr/bin/env perl
BEGIN { push @ARGV, qw(--environment=development) }
use Modern::Perl;
use Dancer;
load_app 'Tutu';
# single-quoting here is deliberate
$Tutu::webmaster_name = q($WEBMASTER_NAME);
$Tutu::webmaster_mail_address = q($WEBMASTER_MAIL_ADDRESS);
$Tutu::website_url = q($WEBSITE_URL);
$Tutu::website_name = q($WEBSITE_NAME);
dance;
