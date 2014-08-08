package Perldoc::Simple::Controller::Pod;
use Moose;
use namespace::autoclean;
use Pod::Simple::HTML;
use System::Command;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

Perldoc::Simple::Controller::Pod - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
    $c->response->body('Matched Perldoc::Simple::Controller::Pod in Pod.');
}

sub regex :LocalRegex('^([^/]+)/?(.+)$') {
    my ( $self, $c ) = @_;
	my $config = $c->config;
	my $page = $c->req->captures->[1];
	my $lang = $c->req->captures->[0];
	if ($lang eq 'JA') {
		$config->{perldoc_opt} = [qq(-L $lang)];
		$config->{ENV}{LC_ALL} = 'ja_JP.UTF-8';
	} else {
		$lang = '';
		$config->{perldoc_opt} = [];
		$config->{ENV}{LC_ALL} = 'en_US.UTF-8';
	}
	my $p = Pod::Simple::HTML->new;
	$p->output_string(\my $html);
	$p->perldoc_url_prefix($c->uri_for."/$lang/");
	$p->man_url_prefix($config->{man});
	$p->html_css($c->uri_for('/screen.css'));
	$p->no_errata_section(1);
	$p->complain_stderr(1);
	$p->index(1);
	local %ENV = %ENV;
#	while (my ($k, $v) = each %{$config->{ENV}}) { $ENV{$k} = $v }
	my @perldoc = (@{$config->{perldoc}}, @{$config->{perldoc_opt}}, $page || '-h');
	my $cmd = System::Command->new(@perldoc);
	my ($stdout, $stderr) = ($cmd->stdout, $cmd->stderr);
	my @out = <$stdout>; my @err = <$stderr>;
	$cmd->close();
	if ($cmd->exit == 0 && @out) {
		unless (grep /^=encoding/, @out) {
			unshift(@out, "=encoding utf8\n", "\n");
		}
		$p->parse_string_document(join('', @out));
		$c->res->body($html);
		return;
	}
	$c->res->body("No documentation found for '$page'");
}

=head1 AUTHOR

MASUDA Yuta

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
