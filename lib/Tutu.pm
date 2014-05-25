package Tutu;
use Modern::Perl;
use Cwd;
use Data::Dumper::Concise;
use Dancer ':syntax';
use Dancer::Error;
use Dancer::Session;
use Crypt::PasswdMD5;
use Text::Markdown 'markdown';
use File::Basename 'fileparse';
use File::Slurp;
use File::Find::Rule;
use Tutu::Utils qw(index_directories find_user remote_reminder send_user_password);

use Cwd;
our $VERSION = 0.01;
our $ABSTRACT = "Tutu - a skimpy outfit for Dancer";
our ($root, $page_dir, $form_dir, $public, $access, $restricted,
	$passwd, %passwd, %salt, %access, %is_restricted, %render);
	
sub website_init {
	$root = shift // '.'; 
	$VERSION = '0.1';
	$page_dir = "$root/pages"; 
	$form_dir = "$root/forms"; 
	$public = "$root/public";
	$access = "$root/access";
	$passwd = "$root/passwd";
	$restricted = "$root/restricted_dirs";
	my @passwd = split "\n",read_file($passwd);
	while( my($user, $hash, $salt) = split " ", shift @passwd )
	{
		$passwd{$user} = $hash;
		$salt{$user} = $salt;
	}
	my @access = split "\n",read_file($access) if -e $access; 
	%access = map{ my($user,$access) = split(" ",$_,2); ($user,$access) } @access;
	%is_restricted = map{ $_, 1} split " ",read_file($restricted) if -e $restricted; 
	%render = ( html => sub{join '',@_},
				md  => sub{markdown(@_)}, 
				txt => sub{markdown(@_)});
}

hook 'before' => sub {
  	if ( 	
			(config->{require_login} and !session('user'))
			and request->path_info !~
			m{(login|bye|reminder-has-been-sent|remind|user-not-found)$}
	) {
  		# Pass the original path requested along to the handler:
  		session requested_path => request->path_info;
		redirect('/login');
  	}
  	elsif ( ! authorized( session('user'), request->path_info)
			and request->path_info ne '/forbidden'){
  		# Pass the original path requested along to the handler:
  		session requested_path => request->path_info;
		redirect('/forbidden');
  	}
};
sub authorized { 
	my ($user, $path) = @_;
	#say "user $user, path $path";
	#say "access: $access{$user}";
	#say Dumper \%access;
	my @parts = grep{ $_ } split '/', $path;
	# is this directory controlled?
	my ($restricted) = grep { $is_restricted{$_} } @parts;
	#say "restricted $restricted";
	return 1 unless $restricted;
	#grep { $restricted eq $_ } split " ",$access{$user}
	#die "path: $path, $access{$user}" if session('user') eq 'joel';
	#die "$access{$user}" if session('user') eq 'joel';
	grep{ $path =~ /\b$_\b/ } split " ",$access{$user}
}

post '/login'    => sub {
	no warnings 'uninitialized';
	if(	exists $passwd{params->{user}} 
			and apache_md5_crypt(params->{pass},$salt{params->{user}}) 
				eq $passwd{params->{user}})
	{
		session user => params->{user};
	my $path = 	'/welcome';
#   	$path = session->{requested_path}
#   		if session->{requested_path} =~ /\w+/ 
# 			and session->{requested_path} !~ /login/;
		session requested_path => undef;
		session failed_login => undef;
		redirect $path;
	} else {
		session failed_login => 1;
		redirect '/login'
	}
};
get  '/login'    => sub { 
	session ident => undef; # if leftover from password reminder
	session user_not_found => undef;
	preprocess('login',"$page_dir/login.md",$render{'md'})};
get  '/logout'    => sub { 
			session->destroy;
			redirect '/bye' };

get '/' => sub { redirect '/welcome' };

get '/forbidden' => sub { forbidden(session->{requested_path}) };

## The following two routes are a hack. The get '/**' route should
## render the /upload route (if user is allowed) and *never* return
## a page for /upload.html

get '/upload' => sub { preprocess('upload', 'pages/upload.html', $render{html}) };
get '/upload.html' => sub { redirect '/upload' };


get '/**' => sub {
	# there is nothing in the /public directory
	# so we serve all requests

	no warnings 'uninitialized';
	my ($matches) = splat;
	my $filename = pop @$matches;

### This code replaces the default serving from /public 
# 	by placing the /public tree under /public/floor
# 
# 	my $search_dir = join '/', $public, 'floor', @$matches;
# 	# first look for a matching file to return
# 
# 	my ($filepath) = File::Find::Rule
#                 ->file()
#                 ->name($filename)
#                 ->in($search_dir);
# 	
# 	my @parts = split '/',$filepath;
# 	shift @parts if $parts[0] eq 'public';
# 	#die Dumper \@parts; # floor images chicago400.jpg
# 	if ($filepath){
# 		my ($ext) = $filename =~ /\.(\w+)$/;
# 		my %force_download = map{$_ => 1 } qw(mpeg mp3 m4v mp4 mpg dvd iso zip);
# 		my @args;
# 		headers 'Content-disposition', qq(attachment; filename="$filename")
# 			if $force_download{$ext};	
# 		content_type 'application/octet-stream';
# 		
# 		# /floors/image/chicago400.jpg
# 		send_file(join('/', undef,@parts), @args);
# 	}
	if (0){}
	else # maybe we have an .html .txt or .md file to serve ?
	{ 
				my ($file) = File::Find::Rule->file()
                                     ->name( "$filename*" )
                                     ->in(join '/',$page_dir, @$matches);
				if ( ! $file ) { err_not_found($file) }
				else { 
					my ($name, $path, $ext1);
					my ($ext) = $file =~ /\.(\w+)$/;
					($name, $path, $ext1) = fileparse($file,$ext);
					preprocess($name, $file, $render{$ext});
				}
	}
				
};
post '/remind'    => sub {
	my $ident = params->{ident};
 	my $result = find_user($ident) ;
	session user_not_found => undef;
 	if ($result)
	{ 
		if ( -f 'pass' ) # we have the password file on hand
			{ send_user_password($result->{user}) }
		else { remote_reminder($result->{user}) }
		session ident => $ident;
		redirect '/reminder-has-been-sent';
	}
 	else 
	{ 
 		session user_not_found => $ident;
	  	redirect '/remind'
 	}
};
post '/upload-file'    => sub {
	
	my ($name, $section, $description) ;
	{ 
		no warnings 'uninitialized';
		($name, $section, $description) 
			= (params->{filename}, params->{category}, params->{description});
	}
	my $file = request->upload('filename');
	defined $file or redirect '/upload-failed';
	my $destination = "$root/uploads";
	$destination .= $section if $section;
	$destination .= "/$name";
	$file->copy_to($destination);
	session uploaded_file_path => $destination;
	session uploaded_file_name => $name;
	redirect '/upload-succeeded';
};
sub err_not_found { 
	my $path = shift;
	final_output("Error 404: file not found", 
qq(

The following file or page you requested was not found:
<p>
<h2>$path</h2>
<p>
Please contact the webmaster if you think
this message was received in error.
)
)
}

sub forbidden { 
	my $path = shift;
	final_output("Error 404: forbidden", 
qq(

Your account lacks permission to access the following file or page:
<p>
<h2>$path</h2>
<p>
Please contact the webmaster if you think
this message was received in error.
)
)
}

sub preprocess {
		my ($topic, $path, $preprocess) = @_;
		# $topic:      page name
		# $preprocess: coderef to return content
		$preprocess //= sub { @_ }; # return content unchanged
		if (-r $path){  
			my $text = read_file($path);
			my $body = $preprocess->($text);
			final_output($topic, $body);
		}
		else { err_not_found($path) }
}

sub final_output {
		my ($topic, $body) = @_;
		template 'default.tt', 
				 {body  => $body,
				  topic => $topic,
				 }, 
				 {layout => undef };

}
true;
__END__

=pod

=head1 NAME

Tutu - a skimpy outfit for Dancer 

=head1 SYNOPSIS


	cd $TUTU_BUILD_DIRECTORY

	$EDITOR MY_WEBSITE_INIT

	tutu-configure MY_WEBSITE_INIT

	# move $WEBSITE_ROOT and $WEBSITE_DOMAIN directories 
	# to appropriate places if necessary
	
	cd $WEBSITE_ROOT

	./dance.psgi # point your browser at http://localhost:3000


=head1 DESCRIPTION

Outfitted with Tutu, Dancer performs page
rendering, access control and file up/downloading. Tutu
also includes utilities for:

=over 8

=item tutu-genapp : create and configure a new webapp 

=item tutu-index : generate file directory listings

=item tutu-pass : generate passwd file

=item tutu-sync : synchronize the website with local development environment

=back

=head1 LICENSE

This module is free software and is published under the same
terms as Perl itself.

=cut
