# -*- mode: perl; coding: utf-8; tab-width: 4; -*-

=encoding utf8

=cut

package Plack::App::Perldoc::Simple;

use common::sense;
use Plack::App::URLMap;

our $VERSION = '0.01';

sub new {
	my $class = shift;
	my @perldoc = qw(perldoc -u -T);
	@perldoc = qw(perlfind -u -T) if eval { require "App::perlfind" };
	my $self = bless {
		perldoc => [@perldoc],
		perldoc_opt => [],
		ENV => { LC_ALL => 'en_US.UTF-8' },
		man => '/man', pod => '/pod',
		section => [1..9],
		@_,
	};
	my $app = Plack::App::URLMap->new;
	$app->mount("$self->{man}$_"   => sub { $self->man2html(@_) })
		for @{$self->{section}};
	$app->mount("$self->{man}.css" => sub { $self->man2html_css });
	$app->mount( $self->{pod}      => sub { $self->perldoc(@_) });
	$app->mount("$self->{pod}.css" => sub { $self->perldoc_css });
	$app->to_app;
}

sub wrap {
	$_[0]->new;
}

use Pod::Simple::HTML;
use System::Command;
use Encode;

sub perldoc {
	my $self = shift;
	my $env = shift;
	(my $page = $env->{PATH_INFO}) =~ s!^/!!;
	my $p = Pod::Simple::HTML->new;
	$p->output_string(\my $html);
	$p->perldoc_url_prefix($env->{SCRIPT_NAME} . '/');
	$p->man_url_prefix($self->{man});
	$p->html_css("$self->{pod}.css");
	$p->no_errata_section(1);
	$p->complain_stderr(1);
	$p->index(1);
	local %ENV = %ENV;
	while (my ($k, $v) = each %{$self->{ENV}}) { $ENV{$k} = $v }
	my @perldoc = (@{$self->{perldoc}}, @{$self->{perldoc_opt}}, $page || '-h');
	my $cmd = System::Command->new(@perldoc);
	my ($stdout, $stderr) = ($cmd->stdout, $cmd->stderr);
	my @out = <$stdout>; my @err = <$stderr>;
	$cmd->close();
	if ($cmd->exit == 0 && @out) {
		unless (grep /^=encoding/, @out) {
			unshift(@out, "=encoding utf8\n", "\n");
		}
		$p->parse_string_document(join('', @out));
		return [ 200, [ 'Content-Type' => 'text/html' ], [ $html ], ];
	}
	[ 200, [ 'Content-Type' => 'text/plain' ], [
		  "No documentation found for for '$page'\n", @err ], ];

=begin comment

	[ 200, [ 'Content-Type' => 'text/html' ], [ <<"----" ], ];
<html>
<title>@perldoc</title>
<link rel="stylesheet" href="$self->{pod}.css" type="text/css">
</head>
<body class='pod'>
No documentation found for for '$page'
<pre> @err</pre>
</body>
</html>
----

=end comment

=cut

}


sub man2html {
	my $self = shift;
	my $env = shift;
	(my $section = $env->{SCRIPT_NAME}) =~ s!$self->{man}!!;
	(my $topic = $env->{PATH_INFO}) =~ s!/!!;
	local %ENV = %ENV;
	while (my ($k, $v) = each %{$self->{ENV}}) { $ENV{$k} = $v }
	my @man2html = qw(man2html --bare --nodepage);
	(my $body = `man $section $topic | @man2html -`) =~
		s!<B>([^\(<]+)\((\d[^\)<]*)\)</B>!<a href="$self->{man}$2/$1">$&</a>!g;
	my $man = $self->{man};
	$body=~ s!(<a href="${man}[^/]*/)\U$topic(">)!$1$topic$2!g;
	if ($body =~ /$topic/) {
		return [ 200, [ 'Content-Type' => 'text/html' ], [ <<"----" ], ];
<html>
<head>
<title>$topic($section)</title>
<link rel="stylesheet" href="$man.css" type="text/css">
</head>
<body class='man'>
$body
</body>
</html>
----
	}
	[ 200, [ 'Content-Type' => 'text/plain' ],
	  [ "No manual entry for $topic" ] ];
}


sub man2html_css {
	my $self = shift;
	my $common = $self->common_css->[2];
	[ 200, [ 'Content-Type'=>'text/css' ], [
		  @$common, <<"----" ] ];
.man {
    line-height: 1.4;
}
----
}

sub perldoc_css {
	my $self = shift;
	my $common = $self->common_css->[2];
	[ 200, [ 'Content-Type'=>'text/css' ], [
		  @$common, <<"----" ] ];
.pod {
    line-height: 1.6;
}

.indexgroup {
    float: right;
    width: 30%;
    background-color: #f8f8f8;
    border: solid 1px #d0d0d0;
    border-radius: 5px;
    margin: 1em 0 1em 1em;
    padding: 1ex 1em;
}

.indexItem1 { margin: 0 0 0 -1.5em; }
.indexItem2 { margin: 0 0 0 -1.5em; }
.indexItem3 { margin: 0 0 0 -1.5em; }

TABLE {
    border-collapse: collapse;
    border-spacing: 0;
    border-width: 0;
    color: inherit;
}

code {
    background-color: #f8f8f8;
    border: solid 1px #e8e8e8;
    border-radius: 4px;
    padding: 0.2ex 0.4ex;
    line-height: 1.3;
}

PRE {
    background: #eeeeee;
    border: 1px solid #888888;
    border-radius: 5px;
    color: black;
    font-family: consolas, monospace;
    line-height: 1.3;
    margin: 1em;
    padding: 1em 0;
    white-space: pre;
}

.block {
    background: transparent;
}

TD .block {
    color: #006699;
    background: #dddddd;
    padding: 0.2em;
    font-size: large;
}
----
}

sub common_css {
	my $self = shift;
	[ 200, [ 'Content-Type'=>'text/css' ], [ <<"----" ]];
BODY {
    background: white;
    color: black;
    font-family: times, serif;
    font-size: 10.5pt;
    line-height: 1.6;
    width: 80%;
    margin: 1ex 10%;
    padding: 1ex;
}

code, var, samp, kbd, tt {
    font-family: consolas, monospace;
}

A:link, A:visited {
    background: transparent;
    color: #006699;
}

H1 {
    background: transparent;
    color: #006699;
    font-size: x-large;
    font-family: tahoma,sans-serif;
}

H2 {
    background: transparent;
    color: #006699;
    font-size: large;
    font-family: tahoma,sans-serif;
}

HR {
    display: none;
}
----
}

1;
__END__

=head1 NAME

Plack::App::Perldoc::Simple - Perl extension for Perldoc

=head1 SYNOPSIS

  plackup -MPlack::App::Perldoc::Simple -e 'Plack::App::Perldoc::Simple->new'

=head1 DESCRIPTION

=head1 SEE ALSO

L<Plack::App::URLMap>,
L<Apache2::Pod>,
L<App::perlfind>,
man2html


=head1 AUTHOR

KUBO Koichi, E<lt>k@obuk.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 by KUBO Koichi

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.20.0 or,
at your option, any later version of Perl 5 you may have available.

=cut
