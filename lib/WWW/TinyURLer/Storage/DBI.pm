package WWW::TinyURLer::Storage::DBI;

use strict;
use warnings;

use DBI;
# use base 'WWW::TinyURLer::Storage::BaseClass';

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

sub _deploy {
    my $self = shift;
    my $dbh = $self->{dbh};
    my $drop_table = "DROP TABLE IF EXISTS tinyurler";
    $dbh->do($drop_table) or die $dbh->errstr;
    my $table_create_sql = "
            CREATE TABLE 'tinyurler' (
                'target_url'        TEXT,
                'destination_url'   TEXT,
                'expires_at'        TEXT,
            PRIMARY KEY(target_url)
            )";
    $dbh->do($table_create_sql) or die $dbh->errstr;
    return 1;
}

sub insert {
    my ($self,@args) = @_;
    die 'You need three arguments to create a record' unless 3 == scalar @args;
    my $insert_sql = sprintf(
        "INSERT INTO tinyurler ('target_url','destination_url','expires_at') VALUES ('%s','%s','%s')",
        @args );
    $self->{dbh}->do($insert_sql) or die $self->{dbh}->errstr;
    return 1;
}

sub find {
     my ($self,$target_url) = @_;
     die unless $target_url;
     my $select_sql = sprintf(
        "SELECT * FROM tinyurler WHERE target_url='%s'",
        $target_url );
    my $sth = $self->{dbh}->prepare($select_sql);
    $sth->execute();
    return $sth->fetchrow_hashref;
}

sub update {
    my ($self,@args) = @_;
    die 'You need two arguments to create a record' unless 2 == scalar @args;
    my $update_sql = sprintf(
        "UPDATE tinyurler SET destination_url='%s' WHERE target_url='%s'",
        $args[1], $args[0] );
    $self->dbh->do($update_sql) or die $self->dbh->errstr;
    return 1;
}

# sub expire {
#     my ($self,$target_url) = @_;
#     die unless $target_url;
#     my $expire_sql = sprintf(
#         "UPDATE tinyurler SET expires_at='%s' WHERE target_url='%s'",
#         'FOO', $target_url );
#     $self->dbh->do($expire_sql) or die $self->dbh->errstr;
#     return 1;
# }

sub DESTROY {
    my $self = shift;
    $self->{dbh}->disconnect or warn $self->{dbh}->errstr;
}
1;
