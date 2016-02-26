package WWW::TinyURLer::Storage;

use strict;
use warnings;
use Class::Load 'load_class';

sub new {
    my $class = shift;
    my $object = shift;
    return bless $object, $class;
}

sub new_from_config {
    my $class = shift;
    my $config = shift;
    
    die "You must specify a config for a storage engine"
        unless ($config);
    
    my $engine_class = __PACKAGE__ . '::' . $config->{engine};
    load_class($engine_class);
    my $engine_config = $config->{engines}->{$config->{engine}};
    my $engine = $engine_class->new_from_config($engine_config);
    
    my $object = { engine => $engine };
    my $storage = $class->new( $object );
    return $storage;
}

=head2

this should create a table in the storage

$self->create(short_url,$long_url,expires_on)

=cut

sub create {
    ...
}

=head2

this should find a given record within the storage

$self->find(short_url)

if a row is found then return the row, if not return undef.

=cut

sub find {
    ...
}

=head2

this should combine both the find and create, if you find it return the record
if not create and return that instead

$self->find_and_create(short_url,$long_url,expires_on)


=cut

sub find_and_create {
    ...
}

=head2

update a given record

$self->update(short_url,$long_url)

=cut

sub update {
    ...
}

=head2

update the expire on to be todays date

$self->expire(short_url)

=cut

sub expire {
    ...
}

1;