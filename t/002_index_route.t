use Test::More tests => 1;
use strict;
use warnings;
ok(1,"dummy test");
__END__
# the order is important
use Dancer::Test;

route_exists [GET => '/'], 'a route handler is defined for /';
response_status_is ['GET' => '/'], 200, 'response status is 200 for /';
response_content_like [GET => '/'], qr/It Works.*I'm in.*index.tt/s,
    'content looks OK for /';
