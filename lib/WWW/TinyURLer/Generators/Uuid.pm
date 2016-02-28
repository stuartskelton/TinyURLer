package WWW::TinyURLer::Generators::Uuid;

use strict;
use warnings;
use base 'WWW::TinyURLer::Generators';
use Data::UUID;

sub new {
    my $class = shift;
    my $object = shift;
    #  set some defaults
    $object->{uuid} = Data::UUID->new;
    return bless $object, $class;
}


sub generate_key_sub {
    my $self = shift;
    return sub{ return $self->generate_key() }
}

sub generate_key {
    my ($self,$args) = @_;
    return  $self->{uuid}->create_str();
}


1;
