#!/usr/bin/env perl
use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/extlib/lib/perl5";
use lib "$FindBin::Bin/lib";
use File::Basename;
use File::Temp qw/tempdir/;

use JSON;
use AnyEvent;
use PocketIO;
use Time::Piece;
use Log::Minimal;
use Getopt::Long; 
use Parallel::Prefork;
use Parallel::Scoreboard;

use Plack::Loader;
use Plack::Builder;
use Twiggy::Server;

use PocketStat::Web;
use PocketStat::Monitor::CPU;

$Log::Minimal::AUTODUMP = 1;
$Log::Minimal::COLOR = 1;

my $host = 0;
my $port = 5000;
my $back_data_length = 300;

GetOptions(
    'port=s'     => \$port,
    'length=i'   => \$back_data_length,
);

my $root_dir = File::Basename::dirname(__FILE__);
my $sc_board_dir = tempdir( CLEANUP => 1 );
my $scoreboard = Parallel::Scoreboard->new( base_dir => $sc_board_dir );

my $monitor_proc_count = 1;   # TODO. only Monitor::CPU;

my $pm = Parallel::Prefork->new({
        max_workers     => $monitor_proc_count + 1,  # Web + Monitors
        spawn_interval  => 1,
        trap_signals    => {
            map { ($_ => 'TERM') } qw(TERM HUP)
        }
    });

while ($pm->signal_received ne 'TERM' ) {
    $pm->start(sub{
            my $stats = $scoreboard->read_all;
            my %running;
            $running{worker} = 0;
            for my $pid ( keys %{$stats} ) {
                my $v = decode_json $stats->{$pid};
                debugf("process [%s] [%s]",$pid, $v);
                $running{$v->{type}}++;
            }

            if($running{worker} >= $monitor_proc_count){
                my $app = builder {
                    enable "Plack::Middleware::AccessLog", format => "combined";

                    enable 'Plack::Middleware::Static', 
                    path => qr{^(?:/static/|/robot\.txt$|/favicon.ico$)},
                    root => "$root_dir/public";

                    mount '/socket.io' => PocketIO->new( 
                        instance => PocketStat::Web->new(scoreboard => $scoreboard),
                        method   => 'run',
                    );

                    mount '/' => Plack::App::File->new(file => "public/index.html");
                };

                my $server = Twiggy::Server->new(
                    host => $host || 0,
                    port => $port,
                )->register_service($app);

                infof("Twiggy starting.. http://$host:$port");
                AE::cv->recv;
            }
            else {
                $scoreboard->update(encode_json {
                        type => 'worker',
                    });
                PocketStat::Monitor::CPU->run(
                    scoreboard       => $scoreboard,
                    back_data_length => $back_data_length,
                );
            }
        });
}


