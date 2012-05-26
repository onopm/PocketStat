use strict;
use warnings;
use lib qw/lib/;
use Test::More;

BEGIN {
    use_ok 'PocketStat';
    use_ok 'PocketStat::Web';
    use_ok 'PocketStat::SocketIO';
    use_ok 'PocketStat::Data::Flot';
    use_ok 'PocketStat::Monitor::CPU';
}

done_testing;
