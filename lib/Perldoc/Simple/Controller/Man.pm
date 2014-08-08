package Perldoc::Simple::Controller::Man;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

Perldoc::Simple::Controller::Man - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
    $c->res->body('Matched Perldoc::Simple::Controller::Man in Man.');
}

sub regex :LocalRegex('^(.+)$') {
    my ( $self, $c ) = @_;
	my $section = $c->req->captures->[0];
	my $topic = '';				#$env->{PATH_INFO}) =~ s!/!!;
	my @man2html = qw(man2html --bare --nodepage);
	(my $body = `man $section $topic | @man2html -`) =~
		s!<B>([^\(<]+)\((\d[^\)<]*)\)</B>!<a href="$self->{man}$2/$1">$&</a>!g;
	my $man = $self->{man};
	$body =~ s!(<a href="${man}[^/]*/)\U$topic(">)!$1$topic$2!g;
	if ($body =~ /$topic/) {
		$c->stash->{title} = "$topic($section)";
		$c->stash->{content} = $body;
		$c->stash->{template} = 'man.tt';
	} else {
		$c->res->body("No manual entry for $topic");
	}
}


=head1 AUTHOR

MASUDA Yuta

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
