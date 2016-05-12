use base "consoletest";
use testapi;
use mokcommon;

sub run() {
    my $self = shift;

    run_mok_test operation => "enroll", mokx => 0, hash => 1, root_pw => 0;
}

sub test_flags() {
    return {fatal => 1};
}

1;
# vim: set sw=4 et: