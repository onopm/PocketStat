use strict;
use warnings;
use lib qw/lib/;
use Test::More;
use PocketStat::Data::Flot;


is(PocketStat::Data::Flot->new->{back_data_length}, 120);

is(PocketStat::Data::Flot->new(
        back_data_length => 240
    )->{back_data_length}, 240);

my $data = PocketStat::Data::Flot->new(back_data_length => 3);

ok ! $data->label;
ok $data->label([qw/val_A val_B val_C/]);
is_deeply $data->{label}, [qw/val_A val_B val_C/];

$data->append(0,1,2);
is_deeply($data->{data}, [ [0,1,2] ]);
is_deeply($data->latest, { val_A => 0, val_B => 1, val_C => 2 });
is_deeply($data->publish, [
    { data => [ [0,0] ], label => 'val_A',},
    { data => [ [0,1] ], label => 'val_B',},
    { data => [ [0,2] ], label => 'val_C',},
    ]);

$data->append(10,11,12);
is_deeply($data->{data}, [ [0,1,2],[10,11,12] ]);
is_deeply($data->latest, { val_A => 10, val_B => 11, val_C => 12 });
is_deeply($data->publish, [
    { data => [ [-1,0],[0,10] ], label => 'val_A',},
    { data => [ [-1,1],[0,11] ], label => 'val_B',},
    { data => [ [-1,2],[0,12] ], label => 'val_C',},
    ]);


$data->append(20,21,22);
is_deeply($data->{data}, [ [0,1,2],[10,11,12],[20,21,22] ]);
is_deeply($data->latest, { val_A => 20, val_B => 21, val_C => 22 });
is_deeply($data->publish, [
    { data => [ [-2,0],[-1,10],[0,20] ], label => 'val_A',},
    { data => [ [-2,1],[-1,11],[0,21] ], label => 'val_B',},
    { data => [ [-2,2],[-1,12],[0,22] ], label => 'val_C',},
    ]);

#
# back_data_length => 3
#
$data->append(30,31,32);
is_deeply($data->{data}, [ [10,11,12],[20,21,22],[30,31,32] ]);
is_deeply($data->latest, { val_A => 30, val_B => 31, val_C => 32 });
is_deeply($data->publish, [
    { data => [ [-2,10],[-1,20],[0,30] ], label => 'val_A',},
    { data => [ [-2,11],[-1,21],[0,31] ], label => 'val_B',},
    { data => [ [-2,12],[-1,22],[0,32] ], label => 'val_C',},
    ]);

done_testing;
