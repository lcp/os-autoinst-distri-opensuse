use base "opensusebasetest";
use testapi;
use utils;

sub run() {
    my $self = shift;

    select_console 'user-console';

    script_sudo("rpm -e mokutil");

    save_screenshot;

    script_run("rm -f myhash");
}

sub test_flags() {
    return { 'milestone' => 1, 'fatal' => 1, 'important' => 1 };
}

1;

# vim: set sw=4 et:
