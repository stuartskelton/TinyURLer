use Plack::Builder;

use WWW::TinyURLer;

my $app = sub {
    return WWW::TinyURLer::dispatch(@_)
};

builder {
    $app;
};
