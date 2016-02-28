requires 'Class::Load';
reauires 'Data::UUID';
requires 'DBD::SQLite';
requires 'DBI';
requires 'DDP';
requires 'HTTP::Server::Simple::PSGI';
requires 'YAML::Tiny';

on 'develop' => sub {
    recommends 'LWP::UserAgent';
    recommends 'Parallel::ForkManager';
};
