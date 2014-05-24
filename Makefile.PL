use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Tutu',
    AUTHOR              => 'Joel Roth <joelz@pobox.com>',
    VERSION_FROM        => 'lib/Resources.pm',
    ABSTRACT_FROM       => 'lib/Resources.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More'				=> 0,
        'Dancer' 					=> 0,
		'Cwd' 						=> 0,
		'Crypt::PasswdMD5' 			=> 0,
		'Data::Dumper::Concise' 	=> 0,
		'Dancer ' 					=> 0,
		'Dancer::Error' 			=> 0,
		'Dancer::Session' 			=> 0,
		'Email::Stuffer' 			=> 0,
		'File::Basename' 			=> 0,
		'File::Find::Rule' 			=> 0,
		'File::Slurp' 				=> 0,
		'Modern::Perl' 				=> 0,
		'Text::Markdown' 			=> 0,
    },
	EXE_FILES => [ 'bin/tutu-index', 'bin/tutu-pass' ],
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Tutu-*' },
);
