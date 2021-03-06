# SUSE's openQA tests
#
# Copyright © 2016 SUSE LLC
#
# Copying and distribution of this file, with or without modification,
# are permitted in any medium without royalty provided the copyright
# notice and this notice are preserved.  This file is offered as-is,
# without any warranty.

use base "opensusebasetest";
use strict;
use testapi;
use lockapi;
use mmapi;

sub run() {
    # there is only one child
    my $children = get_children();
    my $child_id = (keys %$children)[0];

    assert_screen "remote_slave_ready", 200;

    mutex_create "installation_ready";
    mutex_lock('installation_finished', $child_id);
}

sub test_flags {
    return {fatal => 1};
}

1;
# vim: set sw=4 et:
