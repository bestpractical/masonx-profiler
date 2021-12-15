#!/usr/bin/env perl

use inc::Module::Install;

name		('MasonX-Profiler');
author_from	('lib/MasonX/Profiler.pm');
abstract_from	('lib/MasonX/Profiler.pm');
version_from	('lib/MasonX/Profiler.pm');
requires	('HTML::Mason', 0);
requires	('Time::HiRes', 0);
license		('perl');

WriteAll( sign => 1 );
