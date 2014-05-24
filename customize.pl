#!/usr/bin/env perl
use Modern::Perl;
use Data::Dumper::Concise;

my @customize = split "\n",<<'END';
$WEBSITE_ROOT /home/maxfankel/space
$WEBSITE_DOMAIN maxfankel.com
$WEBSITE_URL http://maxfankel.com
$WEBSITE_NAME Fankel Space Training
$WEBMASTER_NAME Max Fankel
$WEBMASTER_MAIL_ADDRESS me@maxfankel.com
END

my $grep = q(grep -lrP '\$[A-Z]' example.com webroot);
my $targets = join " ",map{chomp; $_} qx($grep);
say "
Searching for files using shell command: 

    $grep
";
say "Found targets: 

    $targets";

# escape sigils

my $rep;
for (@customize)
{
	chomp;
	my ($var, $replacement) = split " ", $_, 2;
	$var =~ s/\s+$//;		
	$replacement =~ s/\s+$//;		

	$replacement =~ s{([\@\$])}{\\$1}g;
	
	
	$var =~ s{\$}{\\\$};
	$rep .= "s{$var}{$replacement}; ";
}

#say Dumper \%replace;
$rep =~ s{'}{&#39;}g;
my $command = qq(perl -p -i.bak -E '$rep' $targets);
say;
say $command;
`$command`;
