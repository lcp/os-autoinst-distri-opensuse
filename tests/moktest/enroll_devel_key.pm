use base "consoletest";
use testapi;

sub run() {
    my $self = shift;
    my $devel_key = 'data/shim-devel.der';
    my $new_shim = 'data/shim-opensuse.efi';

    script_sudo("cp -f $devel_key /boot/efi/");
    script_sudo("cp -f $new_shim /boot/efi/EFI/opensuse/");
    script_sudo("efibootmgr -c -d /dev/vda -l \"\\EFI\\opensuse\\shim-opensuse.efi\" -L \"test\"");
    # boot to the firmware UI
    script_sudo("echo -ne \"\\x07\\x00\\x00\\x00\\x01\\x00\\x00\\x00\\x00\\x00\\x00\\x00\" > /sys/firmware/efi/efivars/OsIndications-8be4df61-93ca-11d2-aa0d-00e098032b8c");
    script_sudo("reboot");

    wait_idle;

    # Go to Device Manager
    send_key "down";
    send_key "down";
    send_key "down";
    send_key "ret";

    sleep 3;
    save_screenshot;

    # Into Secure Boot Configuration
    send_key "ret";

    sleep 3;
    save_screenshot;

    send_key "down";
    send_key "down";
    send_key "ret";
    # Set to Custom mode
    send_key "down";
    send_key "ret";

    sleep 3;
    save_screenshot;

    # Custom Secure Boot Options
    send_key "down";
    send_key "ret";

    sleep 3;
    save_screenshot;

    # DB Options
    send_key "down";
    send_key "down";
    sleep 3;
    save_screenshot;
    send_key "ret";
    sleep 3;
    save_screenshot;

    # Enroll Signature
    send_key "ret";
    sleep 3;
    save_screenshot;
    # Enroll Signature Using File
    send_key "ret";
    sleep 3;
    save_screenshot;
    # Choose harddisk
    send_key "down";
    send_key "ret";
    send_key "down";
    send_key "down";
    sleep 3;
    save_screenshot;
    # Choose shim-devel.der
    send_key "ret";

    sleep 3;
    save_screenshot;

    # Commit changes
    send_key "down";
    send_key "down";
    sleep 3;
    save_screenshot;
    send_key "ret";

    sleep 3;
    save_screenshot;

    # Back to the main menu
    send_key "esc";
    send_key "esc";
    send_key "esc";

    sleep 3;
    save_screenshot;

    # continue
    send_key "ret";

    assert_screen "grub2", 15;
    send_key "ret";

    if ( get_var("NOAUTOLOGIN") ) {
        assert_screen 'displaymanager', 300;
    }
    else {
        assert_screen 'generic-desktop', 300;
    }

    save_screenshot;

    # verify there is a text console on tty1
    send_key "ctrl-alt-f1";
    assert_screen "tty1-selected", 15;

    # init
    # log into text console
    send_key "ctrl-alt-f4";
    # we need to wait more than five seconds here to pass the idle timeout in
    # case the system is still booting (https://bugzilla.novell.com/show_bug.cgi?id=895602)
    assert_screen "tty4-selected", 10;
    assert_screen "text-login", 10;
    type_string "$username\n";
    sleep 2;
    assert_screen "password-prompt", 10;
    type_password;
    type_string "\n";
    sleep 3;
    type_string "PS1=\$\n";    # set constant shell promt
    sleep 1;

    script_sudo "chown $username /dev/$serialdev";
}

1;
# vim: set sw=4 et:
