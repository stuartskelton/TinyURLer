package WWW::TinyURLer;

use strict;
use warnings;

use WWW::TinyURLer::Storage;

my $methods = {
    GET     => \&_redirect,
    POST    => \&_create,
    PUT     => \&_update,
    DELETE  => \&_expire,
};

my $name = time;
my $config = {
    storage => {
        engine  => 'DBI',
        engines => {
            DBI => {
                dsn             => "dbi:SQLite:dbname=/TinyURLer/${name}_1.sqlite",
                username        => '',
                password        => '',
                deploy          => 1,
            }
        }
    },
    generate => {
        default => 'string',
        retry_error     => 10,
        generators => {
            string => {
                chars           => '123456789bcdfghjkmnpqrstvwxz', # will be lower cased
                length          => 7, # default
                retry_warning   => 3,
            },
#           uuid => {},
#           words => {
#               default => 'coding',
#               dictionaries => {
#                   en => [
#                       ['two', 'three', 'four', 'five'],
#                       ['red', 'blue', 'green', 'white', 'black'],
#                       ['cars', 'trees', 'balls', 'dogs', 'cats']
#                   ],
#                   nl => [
#                       ['rode', 'blauwe', 'groene', 'witte', 'zwarte'],
#                       ['maandag', 'dinsdag', 'woensdag', 'donderdag', 'vrijdag', 'zaterdag', 'zondag']
#                   ],
#                   coding => [
#                       ['foo', 'bar', 'baz', 'qux'],['foo', 'bar', 'baz', 'qux'],['foo', 'bar', 'baz', 'qux']
#                   ]
#           },
        }
    }
    time_to_life => 48 * 3600,
    publichost => 'localhost',
};

my $storage = WWW::TinyURLer::Storage->new_from_config($config->{storage});

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
