# $File: //member/autrijus/MasonX-Profiler/lib/MasonX/Profiler.pm $ $Author: autrijus $
# $Revision: #5 $ $Change: 8452 $ $DateTime: 2003/10/17 10:52:28 $

package MasonX::Profiler;
$MasonX::Profiler::VERSION = '0.02';

use strict;
use Time::HiRes qw( time );

=head1 NAME

MasonX::Profiler - Mason per-component profiler

=head1 VERSION

This document describes version 0.02 of MasonX::Profiler, released
October 17, 2003.

=head1 SYNOPSIS

In the Mason handler:

    use MasonX::Profiler;
    my $ah = HTML::Mason::ApacheHandler->new(
	preamble => 'my $p = MasonX::Profiler->new($m, $r);',
	# ...
    );

Alternatively, in F<httpd.conf> with L<HTML::Mason::ApacheHandler>:

    PerlModule MasonX::Profiler
    PerlSetVar MasonPreamble "my $p = MasonX::Profiler->new($m, $r);"

=head1 DESCRIPTION

This module prints per-component profiling information to STDERR (usually
directed to the Apache error log).  Its output looks like this:

    =Mason= 210.85.16.204 - /Foundry/Home/MyRequests.html BEGINS
    =Mason= 210.85.16.204 -     /Elements/SetupSessionCookie 0.0610
    =Mason= 210.85.16.204 -         /Callbacks/Foundry/autohandler/Auth 0.0003
    =Mason= 210.85.16.204 -     /Elements/Callback 0.0242
    =Mason= 210.85.16.204 -     /Elements/Callback 0.0016
    =Mason= 210.85.16.204 -                 /Foundry/Elements/Top 0.0604
    =Mason= 210.85.16.204 -                 /Foundry/Elements/Tab 0.0194
    =Mason= 210.85.16.204 -             /Foundry/Elements/Header 0.1375
    =Mason= 210.85.16.204 -             /Foundry/Elements/Tabs 0.0037
    =Mason= 210.85.16.204 -         /Elements/Callback 0.0294
    =Mason= 210.85.16.204 -     /Elements/Footer 0.0308
    =Mason= 210.85.16.204 - /autohandler 2.9179
    =Mason= 210.85.16.204 - /Foundry/Home/MyRequests.html ENDS

Each row contains five whitespace-separated fields: C<=Mason=>, remote IP
address, C<->, indented component name, and the time spent processing that
component (inclusive).  The beginning and end of the initial request is
represented by the special time fields C<BEGINS> and C<ENDS>.

=cut

my %Depth;

sub init {
    my ($class, $p, $m, $r) = @_;
    $_[1] = $class->new($m, $r);
}

sub new {
    my ($class, $m, $r) = @_;

    my $self = {
	start	=> time(),
	uri	=> $r->uri,
	tag	=> $m->current_comp->path,
	ip	=> (
	    eval { $r->connection->get_remote_host(
		Apache::REMOTE_NAME(), $r->per_dir_config,
	    ) } || '*'
	),
    };

    return if $self->{tag} eq '/l';

    print STDERR "=Mason= $self->{ip} - $self->{uri} BEGINS\n"
	unless $Depth{$self->{ip}}{$self->{uri}}++;

    bless($self, $class);
}

sub DESTROY {
    my $self = shift;
    my $indent = ' ' x (4 * --$Depth{$self->{ip}}{$self->{uri}});

    printf STDERR "=Mason= $self->{ip} - $indent" .
		  "$self->{tag} %.4f\n", (time - $self->{start});

    return if $indent;
    print STDERR "=Mason= $self->{ip} - $self->{uri} ENDS\n";
}

1;

=head1 AUTHORS

Autrijus Tang E<lt>autrijus@autrijus.orgE<gt>

=head1 COPYRIGHT

Copyright 2002, 2003 by Autrijus Tang E<lt>autrijus@autrijus.orgE<gt>.

This program is free software; you can redistribute it and/or 
modify it under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>

=cut
