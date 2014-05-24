package Tutu::Utils;
use Modern::Perl;
#use HTML::GenerateUtil qw(escape_uri);
use autodie;
use Data::Dumper::Concise;
use Crypt::PasswdMD5;
use Cwd;
use Email::Stuffer;
use File::Slurp;
require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw( index_directories 
					generate_passwd 
					generate_user_list
					find_user 
					send_user_password 
					remote_reminder 
					send_out_mail);

use vars qw( $website_name $website_url $webmaster_name $webmaster_mail_address );
our $sender = $webmaster_mail_address;

sub index_directories { 
	my $root = shift // getcwd;
	my $fh;
	my $public = "$root/public";
	my $pages  = "$root/pages";
	#$ENV{LANG} = "C";  # dates in non-English locales not supported
	opendir my ($dirh), $public;
	my %exclude = map { $_ => 1 } qw( . .. css images );
	my @top = grep{ ! $exclude{$_} and -d "$public/$_" } readdir $dirh; 
	#say "Top-level: @top";
	my $i++;
	map{
			dir_list(
					source => $public,
					target => $pages,
					current => $_,
					path => [],
			);
	} @top;
}

sub dir_list {
        my %args = @_;
        #print Dumper \%args;
        my @path = $args{path} ? @{ $args{path} } : ();
        my $source = $args{source};
        my $current = $args{current};
        my $target  = $args{target};
        my $output_file = join '/',$target,@path,$current.'.md';
        my $full = join '/',$source,@path,$current;
        chdir $full;

        opendir my($dir), $full;
        # sort order: directories, then files, ignore case
        my @fobj = sort { my $oa = -d $a ? "0$a" : "1$a";
                                          my $ob = -d $b ? "0$b" : "1$b";
                                          lc $oa cmp lc $ob }
                                grep{ $_ and $_ ne '.' and $_ ne '..' } readdir $dir;
        #say "fobj: ", join $/, @fobj;

        open my $fh, '>', $output_file;

        # create directory in pages only if
        # this directory contains a subdirectory

        # e.g. for path
        # /public/audio/foo/bar.mp3
        # /pages/audio/ needed, but not /pages/audio/foo

        my $target_dir = join '/',$target,@path,$current;
        mkdir $target_dir
                if ! -e $target_dir
                and grep { -d $_ } @fobj;

		scalar @fobj or say $fh "This directory is empty";
        for my $name( @fobj ){
                # link path (for URL)
                my $link_path = join_path('', @path, $current, $name);
                #$link_path =~ s/ /%20/g; # replace space with HTML entity
                #my $link = qq( <a href="). escape_uri($link_path).qq(">).escape_uri($name).qq(</a><br />\n);
		my $scrubbed_name = $name;
		$scrubbed_name =~ s/[^A-Za-z0-9\-_.!~*'() ]+//g;
		$scrubbed_name =~ s/ /_/g;
		my $dummy_name = "dummy";
                my $link = qq( <a href="). $link_path.qq(">).$name.qq(</a><br />\n);
                if( -d $name )  # directory
                {
                        opendir my($dirh), $name;
                        my @contents = grep{ $_ ne '.' and $_ ne '..' } readdir $dirh;
                        next unless @contents;
                        #say "name: $name";
                        #say "contents: @contents";
                        print $fh "(dir) $link";
                        #print $fh "test - ",++$i;
                        dir_list(
                                source => $source,
                                target => $target,
                                current => $name,
                                path => [@path, $current],
                        );

                        # recursive dir_list will have chdir'ed, so we need

                        chdir $full;

                }
                elsif( -f $name )       # plain file
                        {
                                my $size = -s $name;
                        #print $fh "test - ",++$i;
                                print $fh klength($size) . $link;
                        }


        }
        close $fh;
}
sub join_path {  join '/', @_ }

sub klength {
        my $n = shift;
        my $unit = " " x 2; # for bytes
        if($n > 1e9){ $n /= 1e9, $unit = 'GB'}
        elsif($n > 1e6){ $n /= 1e6, $unit = 'MB' }
        elsif($n > 1e3){ $n /= 1e3, $unit = 'KB' }
        sprintf("%.1f $unit", $n);
}
sub pad {
        my ($s, $len) = @_;
        sprintf("%*s", $len||10, $s);
}

sub salt {
	my $length = shift;
	my @chars=('a'..'z','A'..'Z','0'..'9','_');
	my $random_string;
	$random_string .= $chars[rand @chars] for (1..$length) ;
	$random_string;
}
sub generate_passwd {
	my $source = shift // 'pass';
	my $target = shift // 'passwd';
	open my $fh, '<', $source;
	open my $out, '>', $target;
	my $date = `date`;
	my ($seconds) = localtime(time);
	say srand(int($seconds**2/3));
	my $line; 
	while( $line = <$fh>){
	next if $line =~ /^#/;
	chomp $line; 
	my ($full, $email,$user,$pass, $allow) = split /\s*:\s*/, $line;
	next unless $allow =~ /yes/;
	my $salt = salt(8);
	my $crypt = apache_md5_crypt($pass, $salt);  # , $salt);
	say $out "$user $crypt $salt";
	}
}
sub generate_user_list {
	my @lines = read_file('pass');
	my $content = join $/,
 		map{ 
 			my $line = $_;
 			my (undef, $email, $user) = split /\s*:\s*/, $line;
 			"$email : $user"  
 		} @lines;
	write_file('users', $content);
}
sub find_user {
	my $user_or_email = shift;
	# we expect to be in Dancer app directory
	my @entries = read_file('users');
	my $body;
	my ($name, $email);
	map { chomp } @entries;
	foreach my $entry( @entries ){
		($name, $email) = split /\s*:\s*/, $entry;
		next if $user_or_email ne $name and $user_or_email ne $email;
		return { user => $name, email => $email};
	}
}
sub send_user_password {
	my $user_or_email = shift;
	my $subject = $website_name;
	# we expect to be in Dancer app directory
	my @entries = read_file('pass');
	my ($name, $email, $username, $password);
	map { chomp } @entries;
	foreach my $entry( @entries ){
		($name, $email, $username, $password) = split /\s*:\s*/, $entry;
		next if $user_or_email ne $username and $user_or_email ne $email;
		last 
	}
	my $body = mail_body($name, $username, $password);
	send_out_mail($email, $body);
}
sub remote_reminder { 
	my $email = shift; # could be email or username
	Email::Stuffer->from($sender)
				   ->to($email)
				   ->subject("CS3Reminder")
				   ->text_body($email)
				   ->send;
	
}
	
sub send_reminder {
	my $email = shift;
	my $result = find_passwd($email);
	if( $result )
	{ 
		send_out_mail($result->{email}, $result->{body});
	 	return 1
	}
}
sub send_out_mail {
	my( $email, $body) = @_; 
	Email::Stuffer->from($sender)
				   ->to($email)
				   ->subject("Reminder")
				   ->text_body($body)
				   ->send;
	
}

sub mail_body {
	my ($name, $username, $password) = @_;
	my ($first) = $name =~ /(.+?)\s*\S*$/;
	#say $first;
<<FORM;
Dear $first,

This automated mail contains your login credentials
for the $website_name training materials website.
Note that these credentials are for your exclusive use.
(Please don't share them.)

<a href=$website_url>$website_name</a>

Your username is $username
Your password is $password

Capitalization *is* signficant ("password" differs from
"PassWord")

Regards,

$webmaster_name
--
FORM
}

1
__END__
