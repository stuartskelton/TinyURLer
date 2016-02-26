use strict;
use warnings;

use DDP;
use WWW::TinyURLer::Storage;

my $name = time;
my $config = {
    engine => 'DBI',
    engines => {
        DBI => {
            dsn => "dbi:SQLite:dbname=/TinyURLer/${name}_1.sqlite",
            username => '',
            password => '',
            deploy => 1,
        },
    },
};

my $storage = WWW::TinyURLer::Storage->new_from_config($config);


# create
for (0..100) {
    $storage->create("url$_","LONG$_",'moo');
}

# do some finds
for (0..100) {
    next unless 0 == $_ % 7;
    $storage->find("url$_");
}

for (0..100) {
    my $url =  0 == $_ % 7 ? "NEWURL$_" : "url$_";
    p $storage->find_and_create($url,"LONG$_",'moo');
}

#  do some updates
for (0..100) {
    next if 0 == $_ % 2;
    $storage->update("url$_","updated$_");
}

# do some expires
for (0..100) {
    next unless 0 == $_ % 10;
    $storage->expire("url$_");
}



