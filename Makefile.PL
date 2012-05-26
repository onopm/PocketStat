use ExtUtils::MakeMaker;

WriteMakefile(
    NAME          => 'PocketStat',
    VERSION_FROM  => 'lib/PocketStat.pm',
    PREREQ_PM     => {
        'JSON'                 => '2.53',
        'Twiggy'               => '0.1020',
        'AnyEvent'             => '7.0',
        'PocketIO'             => '0.13',
        'Smart::Args'          => '0.10',
        'Time::Piece'          => '1.20',
        'Log::Minimal'         => '0.09',
        'Parallel::Prefork'    => '0.13',
        'Parallel::Scoreboard' => '0.03',
        #'IPC::Cmd'             => 0,
    },
    MIN_PERL_VERSION => '5.008001',
);

