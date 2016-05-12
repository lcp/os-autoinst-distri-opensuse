#!/usr/bin/perl -w

package mokcommon;

use base Exporter;
use Exporter;

use strict;

use testapi;

use base "consoletest";

use utils;

our @EXPORT = qw/run_mok_test/;

sub do_mokmanager {
    my %args      = @_;
    my $operation = $args{operation};
    my $mokx      = $args{mokx} // 0;
    my $passwd    = $args{passwd} // $testapi::password;

    my $screen_name = "mokmanager";

    die unless ($operation eq "enroll" || $operation eq "delete");

    if ($mokx) {
        $screen_name .= "-mokx-".$operation;
    }
    else {
        $screen_name .= "-".$operation;
    }

    # Reboot the system to MokManager
    select_console 'user-console';
    become_root;
    script_run("reboot");
    reset_consoles;

    assert_screen "mokmanager", 300;

    send_key "ret";
    assert_screen $screen_name, 10;
    send_key "down";
    send_key "ret";
    assert_screen $screen_name."-continue";
    send_key "down";
    send_key "ret";
    assert_screen "mokmanager-".$operation."-confirm";
    send_key "down";
    send_key "ret";
    assert_screen "mokmanager-".$operation."-password";
    type_string $passwd . "\n";
    assert_screen "mokmanager-reboot";
    send_key "ret";

    # XXX It seems the serial output from MokManager could cause problem
    # later. Matching the GRUB message could work around the issue.
    wait_serial("Welcome to GRUB!");

    wait_boot;
    select_console 'user-console';

    assert_script_sudo "chown $username /dev/$serialdev";
}

sub do_mokutil {
    my %args      = @_;
    my $operation = $args{operation};
    my $mokx      = $args{mokx} // 0;
    my $hash      = $args{hash} // 0;
    my $root_pw   = $args{root_pw} // 0;

    my $mok_key   = 'mok.der';
    my $mok_hash  = '2c5818deb3e08c92a993101d0b2b598233a2bd9bcdf791bf8f0047cf04e8f6db';
    my $command   = "mokutil";

    die unless ($operation eq "enroll" || $operation eq "delete");

    if ($mokx) {
        $command .= " --mokx";
    }

    if ($operation eq "enroll") {
        $command .= " --import";
    }
    else {
        $command .= " --delete";
    }

    if ($hash) {
        $command .= "-hash $mok_hash";
    }
    else {
        $command .= " $mok_key";
    }

    if ($root_pw) {
        $command .= " --root-pw";
    }
    else {
        $command .= " --hash-file myhash";
    }

    assert_script_sudo($command);
}

sub verify_mok {
    my %args      = @_;
    my $operation = $args{operation};
    my $mokx      = $args{mokx} // 0;
    my $hash      = $args{hash} // 0;

    my $mok_key   = 'mok.der';
    my $mok_hash  = '2c5818deb3e08c92a993101d0b2b598233a2bd9bcdf791bf8f0047cf04e8f6db';
    my $command   = 'mokutil';

    die unless ($operation eq "enroll" || $operation eq "delete");

    if ($mokx && $hash && $operation eq "delete") {
        my $moklistxrt = "/sys/firmware/efi/efivars/MokListXRT-605dab50-e046-4300-abb6-3dd810dd8b23";
        $command = "test ! -e $moklistxrt || mokutil --mokx --list-enrolled |grep -q -v $mok_hash";
        assert_script_run($command);
        return;
    }

    if ($mokx) {
        $command .= ' --mokx';
    }

    if ($hash) {
        $command .= " --list-enrolled";
        if ($operation eq 'enroll') {
            $command .= " |grep -q $mok_hash";
        }
        else {
            $command .= " |grep -q -v $mok_hash";
        }
    }
    else {
        $command .= " --test-key $mok_key";

        if ($operation eq 'enroll') {
            $command .= " |grep -q already";
        }
        else {
            $command .= " |grep -q not";
        }
    }

    assert_script_run($command);
}

sub run_mok_test {
    my %args      = @_;
    my $operation = $args{operation};
    my $mokx      = $args{mokx} // 0;
    my $hash      = $args{hash} // 0;
    my $root_pw   = $args{root_pw} // 0;

    select_console 'user-console';

    do_mokutil operation => $operation, mokx => $mokx, hash => $hash, root_pw => $root_pw;

    if ($root_pw) {
        do_mokmanager operation => $operation, mokx => $mokx;
    }
    else {
        do_mokmanager operation => $operation, mokx => $mokx, passwd => "mok test";
    }

    verify_mok operation => $operation, mokx => $mokx, hash => $hash;
    save_screenshot;
}

1;

# vim: sw=4 et
