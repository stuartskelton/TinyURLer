#!/usr/bin/perl
use Parallel::ForkManager;
use LWP::UserAgent;

my $ua = LWP::UserAgent->new;
$ua->timeout(10);


# Max 30 processes because we have 30 nodes in the cluster
my $pm = new Parallel::ForkManager(30);
my $nodes = 30 ;
foreach my $node (0..$nodes) {
    $pm->start and next; # do the fork - the child process skips this    loop
    my $response = $ua->get('http://localhost:5000/');
    if ($response->is_success) {
        print "$node ",$response->status_line,"\n";  # or whatever
    }
    else {
        print "$node ",$response->status_line,"\n";
    }

   $pm->finish; # do the exit in the child process
}
$pm->wait_all_children;

# Example 1: A simple construct for parallelizing.