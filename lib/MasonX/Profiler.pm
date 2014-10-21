# $File: //member/autrijus/MasonX-Profiler/lib/MasonX/Profiler.pm $ $Author: autrijus $
# $Revision: #6 $ $Change: 10396 $ $DateTime: 2004/03/16 10:55:14 $

package MasonX::Profiler;
$MasonX::Profiler::VERSION = '0.03';

use strict;
use Time::HiRes qw( time );

=head1 NAME

MasonX::Profiler - Mason per-component profiler

=head1 VERSION

This document describes version 0.03 of MasonX::Profiler, released
March 16, 2003.

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

Note that if you are using virtual hosts, the two lines above must be
inside the <VirtualHost> block, not outside it.

=head1 DESCRIPTION

This module prints per-component profiling information to STDERR (usually
directed to the Apache error log).  Its output looks like this:

    =Mason= 127.0.0.1 - /NoAuth/webrt.css BEGINS
    =Mason= 127.0.0.1 -     /NoAuth/webrt.css >>>>
    =Mason= 127.0.0.1 -         /Elements/Callback >>>>
    =Mason= 127.0.0.1 -         /Elements/Callback <<<< 0.0008
    =Mason= 127.0.0.1 -     /NoAuth/webrt.css <<<< 0.0072
    =Mason= 127.0.0.1 - /NoAuth/webrt.css ENDS

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

    my $indent = ' ' x (4 * $Depth{$self->{ip}}{$self->{uri}});
    printf STDERR "=Mason= $self->{ip} - $indent".
		  "$self->{tag} >>>>\n";

    bless($self, $class);
}

sub DESTROY {
    my $self = shift;
    my $indent = ' ' x (4 + 4 * --$Depth{$self->{ip}}{$self->{uri}});

    printf STDERR "=Mason= $self->{ip} - $indent".
		  "$self->{tag} <<<< %.4f\n", (time - $self->{start});

    return if $Depth{$self->{ip}}{$self->{uri}};
    print STDERR "=Mason= $self->{ip} - $self->{uri} ENDS\n";
}

1;

=head1 AUTHORS

Autrijus Tang E<lt>autrijus@autrijus.orgE<gt>

=head1 COPYRIGHT

Copyright 2002, 2003, 2004 by Autrijus Tang E<lt>autrijus@autrijus.orgE<gt>.

This program is free software; you can redistribute it and/or 
modify it under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>

=cut
