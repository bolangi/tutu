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

my $new_domain_dir = $replace{'maxfankel.com'};
my $copy_domain_dir_cmd = "cp -a example.com $new_domain_dir";
say "
copying domain directory: 
    $copy_domain_dir_cmd
";
-d $new_domain_dir 
	and say ("directory $new_domain_dir already exists, fix this and try again."),
	exit
or system $copy_domain_dir_cmd;

my ($new_webapp_dir) = $replace{'/home/maxfankel/space'} =~ m{/?([^/]+)/?$};

my $copy_webapp_dir_cmd = "cp -a webapp $new_webapp_dir";
say "
copying webapp directory: 
    $copy_webapp_dir_cmd
";
-d $new_webapp_dir 
	and say ("directory $new_webapp_dir already exists, fix this and try again."),
	exit
or system $copy_webapp_dir_cmd;

my $grep = q(grep -lrP '\$[A-Z]'  $new_webapp_dir);
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
