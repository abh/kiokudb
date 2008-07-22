#!/usr/bin/perl

package MooseX::Storage::Directory::Backend::JSPON::Expander;
use Moose;

use Carp qw(croak);

use MooseX::Storage::Directory::Entry;
use MooseX::Storage::Directory::Reference;

use namespace::clean -except => 'meta';

extends qw(Data::Visitor);

# Note: this method is destructive
# maybe it's a good idea to copy $hash before deleting items out of it?
sub expand_jspon {
    my ( $self, $data, @attrs ) = @_;

    ( my $id = delete $data->{id} )=~ s/\.json$//;

    if ( exists $data->{__CLASS__} ) {
        # check the class more thoroughly here ...
        my ($class, $version, $authority) = (split '-' => delete $data->{__CLASS__});
        local $@;
        my $meta = eval { $class->meta };
        croak "Class ($class) is not loaded, cannot unpack" if $@;
        push @attrs, class => $meta;
    }

    return MooseX::Storage::Directory::Entry->new(
        id   => $id,
        data => $self->visit($data),
        @attrs,
    );
}

sub visit_hash_key {
    my ( $self, $key ) = @_;
    $key =~ s/^public:://x;
    return $key;
}

sub visit_hash {
    my ( $self, $hash ) = @_;

    if ( my $id = $hash->{'$ref'} ) {
        $id =~ s/\.json$//;
        return MooseX::Storage::Directory::Reference->new( id => $id, ( $hash->{weak} ? ( is_weak => 1 ) : () ) );
    } else {
        return $self->SUPER::visit_hash($hash);
    }
}

__PACKAGE__->meta->make_immutable;

__PACKAGE__

__END__

=pod

=head1 NAME

MooseX::Storage::Directory::Backend::JSPON::Expander - Inflate JSPON to entry
data.

=cut


