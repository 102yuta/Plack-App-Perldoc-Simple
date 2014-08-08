use strict;
use warnings;

use Perldoc::Simple;

my $app = Perldoc::Simple->apply_default_middlewares(Perldoc::Simple->psgi_app);
$app;

