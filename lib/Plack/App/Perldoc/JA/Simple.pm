# -*- mode: perl; coding: utf-8; tab-width: 4; -*-

=encoding utf8

=cut

package Plack::App::Perldoc::JA::Simple;

use common::sense;
use base qw(Plack::App::Perldoc::Simple);

our $VERSION = '0.01';

sub new {
	my $class = shift;
	$class->SUPER::new(
		perldoc_opt => [qw(-L JA)], 
		ENV => { LC_ALL => 'ja_JP.UTF-8' },
		@_,
		);
}

1;
__END__

=head1 NAME

Plack::App::Perldoc::JA::Simple - Perl extension for Perldoc -L JA

=head1 SYNOPSIS

  plackup -MPlack::App::Perldoc::JA::Simple -e 'Plack::App::Perldoc::JA::Simple->new'

=head1 DESCRIPTION

=head1 SEE ALSO

L<Plack::App::Perldoc::Simple>

=head1 AUTHOR

KUBO Koichi, E<lt>k@obuk.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 by KUBO Koichi

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.20.0 or,
at your option, any later version of Perl 5 you may have available.

=cut
