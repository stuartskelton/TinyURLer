package WWW::TinyURLer;

use strict;
use warnings;

#use WWW::TinyURLer::Storage;

my $methods = {
    GET     => \&_redirect,
    POST    => \&_create,
    PUT     => \&_update,
    DELETE  => \&_expire,
};

sub dispatch {
use DDP; p @_;
    my $env = shift;
        
    my $method = $methods->{$env->{REQUEST_METHOD}};
    if ($method) {
        return $method->($env);
    }
    
    return [ 405, [], [] ];
}

sub _redirect {
    return [ 307, [ Location => 'http://testserver.com' ], [] ]
}

sub _create {
    return [ 201, [ Location => 'http://testserver.com' ], [] ]
}

sub _update {
    return [ 200, [], [] ]
}

sub _expire {
    return [ 202, [], [ "Goodbye"] ]
}
1;
