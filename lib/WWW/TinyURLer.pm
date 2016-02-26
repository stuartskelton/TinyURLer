package WWW::TinyURLer;

use strict;
use warnings;

use WWW::TinyURLer::Storage;

my $methods = {
    POST        => \&_create,
    GET         => \&_redirect,
    PUT         => \&_update,
    DELETE      => \&_delete,
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
        },
    },
    time_to_life => 48 * 3600,
    publichost => '',
};

my $storage = WWW::TinyURLer::Storage->new_from_config($config->{storage});
my $generator = sub { return $_[0] . (int(6 * rand) +1) };

sub dispatch {
    my $env = shift;
    
    my $method = $methods->{$env->{REQUEST_METHOD}} || 'bad_method';
    return $method->($env);
    
}

sub _create {
    my $env = shift;
    my $destination = "http://my_super_long_URL";
    
    my $new_url = $storage->generate_and_store($generator => { destination_url => $destination });
    
    my $host = $config->{publichost} || $env{HTTP_HOST}
    return [ 201, [ Location => $host . $new_url ], [] ]
};

sub _redirect {
    my $env = shift;
    my $requested = $env->{PATH_INFO};
    
    if ( my $result = $storage->find_redirect($requested) ) {
        return [ 307, [ Location => $result->{destination_url} ], [] ]
    };
    return [ 404, [], [] ];
};

sub _update {
    return [ 200, [], [] ]
};

sub _delete {
    $storage->expire_now();
    return [ 202, [], [ "Goodbye"] ]
};

sub _bad_method {
    return [ 405, [], [] ];
};

1;
