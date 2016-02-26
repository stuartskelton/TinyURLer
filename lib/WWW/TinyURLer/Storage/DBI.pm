package WWW::TinyURLer::Storage::DBI;

use strict;
use warnings;

use DBI;
use base 'WWW::TinyURLer::Storage';

sub new {
    my $class = shift;
    my $object = shift;
    return bless $object, $class;
}

sub new_from_config {
    my $class = shift;
    my $config = shift;
    
    die "You need some connection details" unless ($config);
    my $dbh = $class->_connect_dbh($config);

    my $object = { dbh => $dbh };
    my $engine = $class->new($object);
    
    if ($config->{deploy}) {
        $engine->_deploy;
        $engine->{deploy} = 0;
    };
    
    return $engine;
}

sub _connect_dbh {
    my $class = shift;
    my $config = shift;
    
    my $dbh = DBI->connect(
        $config->{dsn},
        $config->{username} // '',
        $config->{password} // ''
    );
    return $dbh;
}


#
# Attributes
#



#
# Methods
#


sub _deploy {
    my $self = shift;
    my $dbh = $self->{dbh};
    my $drop_table = "DROP TABLE IF EXISTS tinyurler";
    $dbh->do($drop_table) or die $dbh->errstr;
    my $table_create_sql = "
            CREATE TABLE 'tinyurler' (
            'short_url' TEXT,
            'long_url'  TEXT,
            'expires_at'    TEXT,
            PRIMARY KEY(short_url)
            )";
    $dbh->do($table_create_sql) or die $dbh->errstr;
    return 1;
}

sub create {
    my ($self,@args) = @_;
    die 'You need three arguments to create a record' unless 3 == scalar @args;
    my $insert_sql = sprintf(
        "INSERT INTO tinyurler ('short_url','long_url','expires_at') VALUES ('%s','%s','%s')",
        @args );
    $self->dbh->do($insert_sql) or die $self->dbh->errstr;
    return 1;
}

sub find {
     my ($self,$short_url) = @_;
     die unless $short_url;
     my $select_sql = sprintf(
        "SELECT * FROM tinyurler WHERE short_url='%s'",
        $short_url );
    my $sth = $self->dbh->prepare($select_sql);
    $sth->execute();
    return $sth->fetch;
}

sub find_and_create {
    my ($self,@args) = @_;
    my $find = $self->find($args[0]);
    return $find if $find;
    return $self->create(@args);
}

sub update {
    my ($self,@args) = @_;
    die 'You need two arguments to create a record' unless 2 == scalar @args;
    my $update_sql = sprintf(
        "UPDATE tinyurler SET long_url='%s' WHERE short_url='%s'",
        $args[1], $args[0] );
    $self->dbh->do($update_sql) or die $self->dbh->errstr;
    return 1;
}

sub expire {
    my ($self,$short_url) = @_;
    die unless $short_url;
    my $expire_sql = sprintf(
        "UPDATE tinyurler SET expires_at='%s' WHERE short_url='%s'",
        'FOO', $short_url );
    $self->dbh->do($expire_sql) or die $self->dbh->errstr;
    return 1;
}


sub DESTROY {
    my $self = shift;
    $self->{dbh}->disconnect or warn $self->{dbh}->errstr;
}
1;
