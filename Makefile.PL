# -*- mode: perl; coding: utf-8; tab-width: 4; -*-

use ExtUtils::MakeMaker;

WriteMakefile(
    NAME           => 'Plack::App::Perldoc::Simple',
    VERSION_FROM   => 'lib/Plack/App/Perldoc/Simple.pm',
    PREREQ_PM      => {
		'common::sense' => '3.73',
		'Plack' => '1.0031',
		'Pod::Simple::HTML' => '3.28',
		'System::Command' => '1.109',
	},
	ABSTRACT_FROM  => 'lib/Plack/App/Perldoc/Simple.pm',
	AUTHOR         => 'KUBO Koichi <k@obuk.org>',
	LICENSE        => 'perl',
	);
