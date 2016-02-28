package WWW::TinyURLer::Generators;

use strict;
use warnings;
use Class::Load;

sub new {
    my $class = shift;
    my $object = shift;
    return bless $object, $class;
}

sub new_from_config {
    my $class = shift;
    my $config = shift;
    
    die "You must specify a config for a generators" unless ($config);
    die "You must specify default generator." unless ($config->{default});
    my $generators = {};
    
    # load up the generators (this should be refactored)
    while (my ($generator_name,$generator_config) =  each %{$config->{generators}}) {
        my $lc_name = lc $generator_name;
        my $fc_name = ucfirst $lc_name;
        
        my $engine_class = __PACKAGE__ . '::' . $fc_name;
        Class::Load::load_class($engine_class);
            $generators->{$lc_name} = $engine_class->new(
                $config->{generators}->{$lc_name});
    }
    #  now the default, if its in the generators, then use it, else build it
    my $default = $generators->{lc $config->{default}};
    unless ($default){
        my $lc_name = lc $config->{default};
        my $fc_name = ucfirst $lc_name;
        
        my $engine_class = __PACKAGE__ . '::' . $fc_name;
        Class::Load::load_class($engine_class);
        $generators->{$lc_name} = $engine_class->new();
        $default = $generators->{$lc_name};
    }
    
    my $object = { generators => $generators, default => $default};
    my $storage = $class->new( $object );
    return $storage;
}

=head2

generates a random key

$self->get_key()

=cut

sub generate_key {
    my ($self,$config) = @_;
    return $self->{default}->generate_key;
}

sub generate_key_sub {
    my ($self,$config) = @_;
    return $self->{default}->generate_key_sub;
}


1;