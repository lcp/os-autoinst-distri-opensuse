use base "consoletest";
use testapi;
use mokcommon;

sub run() {
    my $self = shift;

    run_mok_test operation => "delete", mokx => 0, hash => 0, root_pw => 1;
}

sub test_flags() {
    return {fatal => 1};
}

1;
# vim: set sw=4 et:
