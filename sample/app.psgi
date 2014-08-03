# -*- mode: perl; coding: utf-8; tab-width: 4; -*-

use common::sense;

use lib qw(../lib);
use Plack::Builder;
builder {
	enable '+Plack::App::Perldoc::JA::Simple';
};
