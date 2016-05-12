use base "consoletest";
use testapi;
use utils;

sub run() {
    my $self = shift;
    my $devel_key = 'data/shim-devel.der';

    select_console 'user-console';
    assert_script_run("curl -L -v " . autoinst_url('data/shim-devel.der') . " > shim-key.der");
    # TODO install the new shim
    script_sudo("cp -f shim-key.der /boot/efi/EFI/shim-key.der");
    # boot to the firmware UI
    assert_script_sudo("echo -ne \"\\x07\\x00\\x00\\x00\\x01\\x00\\x00\\x00\\x00\\x00\\x00\\x00\" > /sys/firmware/efi/efivars/OsIndications-8be4df61-93ca-11d2-aa0d-00e098032b8c");

    become_root;
    type_string "reboot\n";
    reset_consoles;

    assert_screen("ovmf-menu");

    # Go to Device Manager
    send_key "down";
    send_key "down";
    send_key "down";
    send_key "ret";

    assert_screen("ovmf-device-manager");

    # Into Secure Boot Configuration
    send_key "ret";

    assert_screen("ovmf-secure-boot-conf");

    send_key "down";
    send_key "down";
    send_key "down";
    send_key "ret";

    assert_screen("ovmf-change-sb");

    # Set to Custom mode
    send_key "down";
    send_key "ret";

    assert_screen("ovmf-customized-sb");

    # Custom Secure Boot Options
    send_key "down";
    send_key "ret";

    assert_screen("ovmf-sb-option");

    # DB Options
    send_key "down";
    send_key "down";
    send_key "down";

    assert_screen("ovmf-sb-option-db");

    send_key "ret";

    assert_screen("ovmf-db-enroll");

    # Enroll Signature
    send_key "ret";
    assert_screen("ovmf-enroll-sig");

    # Enroll Signature Using File
    send_key "ret";
    wait_idle;
    save_screenshot;
    # Choose harddisk
    #send_key "down";
    send_key "ret";

    assert_screen("ovmf-file-explorer-efi");
    # Choose <EFI>
    send_key "ret";

    wait_idle;
    save_screenshot;

    # Choose <opensuse>
    send_key "down";
    send_key "down";
    send_key "down";
    send_key "down";
    assert_screen("ovmf-choose-shim-key");
    # Choose shim-key.der
    send_key "ret";

    wait_idle;
    save_screenshot;

    # Commit changes
    send_key "down";
    send_key "down";
    assert_screen("ovmf-commit-sig");
    send_key "ret";

    assert_screen("ovmf-sb-option-db");

    # Back to the main menu
    send_key "esc";
    send_key "esc";
    send_key "esc";

    assert_screen("ovmf-menu");

    # continue
    send_key "ret";

    # XXX It seems the serial output from OVMF could cause problem
    # later. Matching the GRUB message could work around the issue.
    wait_serial("Welcome to GRUB!");
    save_screenshot;

    wait_boot;
    select_console 'user-console';

    assert_script_sudo "chown $username /dev/$serialdev";
}

sub test_flags() {
    return { 'important' => 1, 'milestone' => 1, 'fatal' => 1 };
}

1;
# vim: set sw=4 et:
