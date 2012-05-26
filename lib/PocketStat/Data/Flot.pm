package PocketStat::Data::Flot;
use strict;
use warnings;

use Smart::Args;
use Log::Minimal;

sub new {
    args my $class,
    my $back_data_length => { isa => 'Int', default => 120 };

    bless {
        data             => [],
        back_data_length => $back_data_length,
    },$class;
}

sub label {
    my($class, $label) = @_;
    $class->{label} = $label;
}

sub append {
    my $class = shift;

    $class->{latest} = \@_;

    push @{$class->{data}}, [@_];

    if(scalar(@{$class->{data}}) > $class->{back_data_length}){
        #debugf("age over [%s] [%s]", scalar(@{$class->{data}}), $class->{data});
        shift @{$class->{data}};
    }
    else {
        #debugf("age [%s] [%s]", scalar(@{$class->{data}}), $class->{data});
    }
}

sub latest {
    my $class = shift;
    my %ret;

    my @val   = @{$class->{latest}};
    my @label = @{$class->{label}};

    for my $v (@val){
        $ret{shift(@label)} = $v;
    }

    return \%ret;
}

sub publish {
    my $class = shift;
    my @ret_data;

    my $x = 1 - scalar @{$class->{data}};
    #infof("len [%s]",$len);

    my @temp_data;
    for my $data ( @{$class->{data}} ){
        my $j = 0;
        for my $vals ( @$data ){
        #    infof("vals [%s]", $vals);
        #    $ret_data[$i][$j] = $vals;
            push @{$temp_data[$j]},[$x, $vals];
            $j++;
        }
        $x++;
    }

    my @label = @{$class->{label}};
    for my $d (@temp_data){
        push @ret_data, {
            label => shift @label,
            data  => $d,
        };
    }

    #infof("publish return  [%s]", @ret);
    return [@ret_data];
}


1;
