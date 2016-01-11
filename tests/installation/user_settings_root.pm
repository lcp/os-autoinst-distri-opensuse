# SUSE's openQA tests
#
# Copyright © 2009-2013 Bernhard M. Wiedemann
# Copyright © 2012-2016 SUSE LLC
#
# Copying and distribution of this file, with or without modification,
# are permitted in any medium without royalty provided the copyright
# notice and this notice are preserved.  This file is offered as-is,
# without any warranty.

use strict;
use warnings;
use base "y2logsstep";
use testapi;

sub run() {
    my $self = shift;

    assert_screen "inst-rootpassword", 6;
    for (1 .. 2) {
        type_string "$password\t";
        sleep 1;
    }
    assert_screen "rootpassword-typed", 3;
    send_key $cmd{"next"};

    # PW too easy (cracklib)
    # If check_screen added to workaround bsc#937012
    if (check_screen('inst-userpasswdtoosimple', 13)) {
        send_key "ret";
    }
    else {
        record_soft_failure;
    }
}

1;
# vim: set sw=4 et:
