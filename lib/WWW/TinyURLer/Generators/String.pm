package WWW::TinyURLer::Generators::String;

use strict;
use warnings;
use DDP;
use base 'WWW::TinyURLer::Generators';

sub new {
    my $class = shift;
    my $object = shift;
    #  set some defaults
    $object->{length} = 7 unless $object->{length};
    $object->{chars} = default_char_set() unless $object->{chars};
    # generate char_set
    $object->{char_set} = [split( '', $object->{chars} )];
    $object->{char_set_length} = length $object->{chars};
    return bless $object, $class;
}


sub default_char_set {
    return "qwertyuiopasdfghjklzxcvbnm1234567890";
}

sub generate_key_sub {
    my $self = shift;
    return sub{ return $self->generate_key(@_) }
}

sub generate_key {
    my ($self,$args) = @_;
    # self calls to this the length will not be undef
    $args->{length} = $self->{length} unless $args->{length};
    my $letter = $self->{char_set}->[int rand $self->{char_set_length}];
    return $letter if 0 == --$args->{length};
    # protect against minus numbers
    die 'String length should not be a minus number' if 0 > $args->{length};
    return $letter . $self->generate_key($args);
}


1;
