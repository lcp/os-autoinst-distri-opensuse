use base "consoletest";
use testapi;

sub run() {
    my $self = shift;
    my $distri  = get_var("DISTRI");
    my $version = get_var("VERSION");

    wait_idle;
    # let's see how it looks at the beginning
    save_screenshot;

    # init
    select_console 'user-console';

    assert_script_sudo "chown $username /dev/$serialdev";

    if ($distri eq "sle-11") {
        assert_script_sudo("/sbin/elilo --refresh-EBM");
    }

    if ($distri eq "opensuse") {
        become_root;
        script_run "systemctl mask packagekit.service";
        script_run "systemctl stop packagekit.service";

        save_screenshot;

        # Install mokutil
        script_run("zypper -n in mokutil && echo 'installed' > /dev/$serialdev");
        wait_serial("installed", 300) || die "zypper install failed";

        send_key "ctrl-l";

        save_screenshot;

        # Return to the normal user
        script_run "exit";
    }

    script_run("mokutil --generate-hash=\"mok test\" > myhash");
    assert_script_run("test -s myhash");

    assert_script_run("curl -L -v " . autoinst_url('/data/mok.der') . " > mok.der");

    save_screenshot;
}

sub test_flags() {
    return { 'important' => 1, 'milestone' => 1, 'fatal' => 1 };
}

1;
# vim: set sw=4 et:
