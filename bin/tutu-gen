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

my $new_domain_dir = $replace{'$WEBSITE_DOMAIN'};
my ($new_webapp_dir) = $replace{'$WEBSITE_ROOT'} =~ m{/?([^/]+)/?$};

say ("$new_domain_dir or $new_webapp_dir already exist.
Will not overwrite. Fix this and run the script again."), exit
	if -d $new_domain_dir or -d $new_webapp_dir;
my $copy_domain_dir_cmd = "cp -a example.com $new_domain_dir";
say "
copying domain directory: 
    $copy_domain_dir_cmd
";
system $copy_domain_dir_cmd;


my $copy_webapp_dir_cmd = "cp -a webapp $new_webapp_dir";
say "
copying webapp directory: 
    $copy_webapp_dir_cmd
";
system $copy_webapp_dir_cmd;

my $grep = qq(grep -lrP '\\\$[A-Z]'  $new_domain_dir $new_webapp_dir);
my $targets = join " ",map{chomp; $_} qx($grep);
say "
Searching for files using shell command: 

    $grep
";
say "Found targets: 

    $targets";

$rep =~ s{'}{&#39;}g;
my $command = qq(perl -p -i -E '$rep' $targets);
say "shell command";
say $command;
`$command`;
