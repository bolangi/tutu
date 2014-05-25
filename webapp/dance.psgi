#!/usr/bin/env perl
BEGIN { push @ARGV, qw(--environment=development) }
use Modern::Perl;
use Dancer;
load_app 'Tutu';
# easier to put these all together here than duplicate
# them in development.yml and production.yml
# single-quoting here is deliberate
$Tutu::webmaster_name = q($WEBMASTER_NAME);
$Tutu::webmaster_mail_address = q($WEBMASTER_MAIL_ADDRESS);
$Tutu::website_url = q($WEBSITE_URL);
$Tutu::website_name = q($WEBSITE_NAME);
$Tutu::require_login = q($REQUIRE_LOGIN);
Tutu::website_init();
dance;
