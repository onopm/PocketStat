package PocketStat::SocketIO;
use strict;
use warnings;

use JSON;
use AnyEvent;
use PocketIO;
use Time::Piece;
use Log::Minimal;

$Log::Minimal::AUTODUMP = 1;

sub new {
    my($class, %opt) = @_;

    bless{%opt},$class;
}

sub run {
    my($class) = @_;
    #infof("class [%s]", $class);

    return sub {
        my($self, $env) = @_; # PocketIO::Socket
        debugf("handler [%s]", $self);
        #infof("env [%s]", $env);  # $env == $self->{conn}{on_connect_args};

        my $scoreboard = $class->{scoreboard};

        $self->{ev} = AnyEvent->timer(
            interval => 1,
            cb => sub {
                my $now = localtime(AE::now);
                my $sec = int($now->strftime("%S"));

                my @vmstat_pie;
                my $vmstat_flot;

                my $stats = $scoreboard->read_all;
                for my $pid ( keys %{$stats} ) { 
                    my $v = decode_json $stats->{$pid}; 
                    debugf("process [%s] [%s]", $pid, $v);

                    if($v->{type} eq 'worker'){
                        for my $label (@{$v->{label}}){
                            #debugf("v:[%s] [%s]",$label, $v->{val}{$label});
                            push @vmstat_pie, {
                                data => [[1, $v->{val}{$label}]],
                                label => $label,
                            }
                        }
                        $vmstat_flot = $v->{flot};
                    }
                }
                #infof("flot: [%s]", $vmstat_flot);

                #debugf("emit [%s]", $sec);
                $self->emit('data',{ 
                        time => $now->strftime("%Y/%m/%d %H:%M:%S"), 
                        sec  => $sec, 
                        data_pie => [ 
                        { data => [[0, $sec]], label => 'sec', color => '#CCC'}, 
                        { data => [[0, (60-$sec)]], label => '',color=>'black' }, 
                        ],
                        vmstat_pie => [@vmstat_pie],
                        vmstat_flot => $vmstat_flot,
                    });
            }); # $self->{ev}
    };
}

1;





