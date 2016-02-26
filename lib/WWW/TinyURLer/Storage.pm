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

=head2 create

Create a new entry in the table and return the short URL on succes.

    $storage->create($generator, $row_hash_ref)

=over

=item $generator

A Coderef that will generate a (random) string.

=item $row_hash_ref

A hashref of the row data to be inserted in the table

=back

=cut

sub create {
    return [ 201, [ Location => 'http://testserver.com' ], [] ]
}

=head2 find

this should find a given record within the storage

$self->find(short_url)

if a row is found then return the row, if not return undef.

=cut

sub redirect {
    return [ 307, [ Location => 'http://testserver.com' ], [] ]
}


=head2

update a given record

$self->update(short_url,$long_url)

=cut

sub update {
    return [ 200, [], [] ]
}

=head2

update the expire on to be todays date

$self->expire(short_url)

=cut

sub expire {
    return [ 202, [], [ "Goodbye"] ]
}

sub bad_method {
    return [ 405, [], [] ];
}
1;