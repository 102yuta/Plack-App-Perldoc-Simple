use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Perldoc::Simple';
use Perldoc::Simple::Controller::Man;

ok( request('/man')->is_success, 'Request should succeed' );
done_testing();
