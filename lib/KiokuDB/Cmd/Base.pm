#!/usr/bin/perl

package KiokuDB::Cmd::Base;
use Moose;

use namespace::clean -except => 'meta';

extends qw(MooseX::App::Cmd::Command);


# this is to enable programatic usage:

has '+usage' => ( required => 0 );

has '+app'   => ( required => 0 );

has verbose => (
    isa => "Bool",
    is  => "ro",
    cmd_aliases => "v",
    documentation => "more output",
);

sub BUILD {
    my $self = shift;

    STDERR->autoflush(1) if $self->verbose;
}

sub v {
    my $self = shift;
    return unless $self->verbose;

    STDERR->print(@_);
}

sub run {
    my $self = shift;

    my $t = -time;
    my $tc = -times;

    inner();
    
    $t += time;
    $tc += times;

    $self->v(sprintf "completed in %.2fs (%.2fs cpu)\n", $t, $tc);
}

__PACKAGE__->meta->make_immutable;

__PACKAGE__

__END__
