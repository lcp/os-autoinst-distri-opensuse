use base "basetest";
use testapi;

sub run() {
    my $self = shift;
    my $distri  = get_var("DISTRI");

    check_screen([qw/bootloader-shim-import-prompt bootloader-grub2/], 15);
    if (match_has_tag("bootloader-shim-import-prompt")) {
        send_key "down";
        send_key "ret";
    }

    # Remove the DVD
    assert_screen "bootloader-grub2", 15;
    eject_cd;
    power("reset");

    if ($distri ne "sle-11") {
        return;
    }

    assert_screen("ovmf-start");

    send_key "esc";

    assert_screen("ovmf-menu");

    send_key "down";
    send_key "down";
    send_key "down";
    send_key "down";

    # Choose Boot Maintenance Manager
    assert_screen("ovmf-boot-maintenance");
    send_key "ret";

    # Boot Maintenance Manager
    assert_screen("ovmf-boot-maintenance-menu");
    send_key "down";
    send_key "down";
    send_key "down";
    
    # Choose Boot From File
    wait_idle;
    save_screenshot;

    send_key "ret";

    # File Explorer
    # HDD
    wait_idle;
    save_screenshot;

    send_key "ret";

    # <efi>
    assert_screen("ovmf-file-efi");
    send_key "ret";

    # <SuSE>
    assert_screen("ovmf-file-suse");
    send_key "down";
    send_key "down";
    send_key "ret";

    # shim.efi
    assert_screen("ovmf-file-bootloaders");
    send_key "down";
    send_key "ret";

    save_screenshot;
}

sub test_flags() {
    return { 'important' => 1, 'milestone' => 1, 'fatal' => 1 };
}

1;
# vim: set sw=4 et:
