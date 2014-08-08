use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Perldoc::Simple';
use Perldoc::Simple::Controller::Pod;

ok( request('/pod')->is_success, 'Request should succeed' );
done_testing();
