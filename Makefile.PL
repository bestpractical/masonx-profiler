#!/usr/bin/env perl
# $File: //member/autrijus/MasonX-Profiler/Makefile.PL $ $Author: autrijus $
# $Revision: #1 $ $Change: 8431 $ $DateTime: 2003/10/16 11:21:57 $

use inc::Module::Install;

requires ('HTML::Mason', 0);
requires ('Time::HiRes', 0);

WriteMakefile (
    AUTHOR	    => 'Autrijus Tang (autrijus@autrijus.org)',
    NAME	    => 'MasonX::Profiler',
    ABSTRACT	    => 'Mason per-component profiler',
    VERSION_FROM    => 'lib/MasonX/Profiler.pm',
    SIGN	    => 1,
);

