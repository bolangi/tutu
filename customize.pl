#!/usr/bin/env perl
use Modern::Perl;
use Data::Dumper::Concise;

my @customize = split "\n",qx(cat ./MY_WEBSITE_INIT);
my %replace;
my $rep;
for (@customize)
{
	chomp;
	my ($var, $replacement) = split " ", $_, 2;
	$var =~ s/\s+$//;		
	$replacement =~ s/\s+$//;		
	$replacement =~ s{([\@\$])}{\\$1}g;

	$replace{$var} = $replacement;
	
	$var =~ s{\$}{\\\$};
	$rep .= "s{$var}{$replacement}; ";
}

my $copy_domain_dir_cmd = "cp -a example.com $replace{'$WEBSITE_DOMAIN'}";
say "
copy domain directory: 
    $copy_domain_dir_cmd
";
system $copy_domain_dir_cmd;

my $copy_webapp_dir_cmd = "cp -a webapp $replace{'$WEBSITE_ROOT'}";
say "
copy webapp directory: 
    $copy_webapp_dir_cmd
";
system $copy_webapp_dir_cmd;


my $grep = q(grep -lrP '\$[A-Z]' example.com webroot);
my $targets = join " ",map{chomp; $_} qx($grep);
say "
Searching for files using shell command: 

    $grep
";
say "Found targets: 

    $targets";

# escape sigils


#say Dumper \%replace;
$rep =~ s{'}{&#39;}g;
my $command = qq(perl -p -i.bak -E '$rep' $targets);
say;
say $command;
`$command`;
