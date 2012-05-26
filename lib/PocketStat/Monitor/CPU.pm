package PocketStat::Monitor::CPU;
use strict;
use warnings;

use JSON;
use Config;
use Smart::Args;
use Log::Minimal;

use PocketStat::Data::Flot; 

sub run {
    args my $class,
    my $scoreboard       => { isa => 'Parallel::Scoreboard'},
    my $back_data_length => { isa => 'Int', default => 60 };

    my $flot = PocketStat::Data::Flot->new(
        back_data_length => $back_data_length,
    );
    my $input = input_type();
    $flot->label($input->{label});

    open my $fh, '-|', $input->{cmd};
    while(my $line = <$fh>){
        $line =~ s/\r?\n$//g;
        next if $line !~ $input->{re};

        $flot->append($1,$2,$3);

        $scoreboard->update(encode_json {                       
                worker => 'cpu',
                type   => 'worker',                               
                cmd    => 'vmstat',
                label  => $input->{label},
                latest => $flot->latest,
                flot   => $flot->publish,  
            });
    }

}

sub input_type {
    my $osname = $Config{osname};
    my $osvers = $Config{osvers};

    return {
        cmd   => 'LANG=C vmstat 1',
        label =>  [ qw/usr sys idle/],
        re    => qr/\s(\d+)\s+(\d+)\s+(\d+)$/,
    } if($osname eq 'solaris');

    return {
        cmd   => 'LANG=C iostat 1',
        label =>  [ qw/usr sys idle/],
        re    => qr/^\s+\d+\s+\d+\s+\d+\s+(\d+)\s+(\d+)\s+(\d+)/,
    } if($osname eq 'darwin');

    if($osname eq 'linux'){
        my $label = [ qw/usr sys idle wio/];
        my $re;
        debugf('linux cmd: [%s]', 'vmstat 1 1');
        my $log = `vmstat 1 1`;

        # Debian: /us sy id wa$/
        if($log =~ /us[a-z]*\s+sy[a-z]*\s+id[a-z]*\s+wa[a-z]*\r?\n/){
            $re = qr/\s(\d+)\s+(\d+)\s+(\d+)\s+(\d+)$/;
        }
        # CentOS: /us sy id wa st$/
        elsif($log =~ /us[a-z]*\s+sy[a-z]*\s+id[a-z]*\s+wa[a-z]*\s+st[a-z]*\r?\n/){ 
            $label = [ qw/usr sys idle wio steal/];
            $re = qr/\s(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)$/;
        }
        else {
            # TODO
            warnf("vmstat parse error.");
        }
        debugf("linux label: [%s]", $label);
        debugf("linux re: [%s]", $re);

        return {
            cmd   => 'LANG=C vmstat 1',
            label => $label,
            re    => $re,
        };
    }

    infof("unknown OS");
    return;
}

1;
