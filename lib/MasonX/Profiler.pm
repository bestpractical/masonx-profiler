# $File: //member/autrijus/MasonX-Profiler/lib/MasonX/Profiler.pm $ $Author: autrijus $
# $Revision: #1 $ $Change: 8431 $ $DateTime: 2003/10/16 11:21:57 $

package MasonX::Profiler;
$MasonX::Profiler::VERSION = '0.01';

use strict;
use Time::HiRes qw( time );

=head1 NAME

MasonX::Profiler - Mason per-component profiler

=head1 SYNOPSIS

    use MasonX::Profiler;
    my $ah = HTML::Mason::ApacheHandler->new(
	preamble => 'MasonX::Profiler->init(my($p), $m, $r);',
    );

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

Each row contains five whitespace-separated fields: C<=Mason=>, remote IP
address, C<->, indented component name, and the time spent processing that
component (inclusive).  The initial request is represented by the special
time field C<BEGINS>.

=cut

my $depth = 0;

sub init {
    my ($class, $p, $m, $r) = @_;
    my $ip = eval { $r->connection->get_remote_host(
	Apache::REMOTE_NAME(), $r->per_dir_config
    ) } or return;
    $_[1] = $class->new( $m->current_comp->path, $r->uri, $ip );
}

sub new {
    my ($class, $tag, $uri, $ip) = @_;

    return if $tag eq '/l';

    my $self = bless({}, $class);

    $self->{tag}   = $tag;
    $self->{start} = time;
    $self->{ip}    = $ip;

    print STDERR "=Mason= $ip - $uri BEGINS\n" unless $depth++;
    return $self;
}

sub DESTROY {
    my $self = shift;
    printf STDERR "=Mason= $self->{ip} - " . (' ' x (--$depth*4)) . "%s %.4f\n",
	$self->{tag}, time - $self->{start};
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
