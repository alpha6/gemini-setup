#!/usr/bin/env perl
# vim:ts=4:sw=4:expandtab
# © 2012 Michael Stapelberg, Public Domain

# This script is a simple wrapper which prefixes each i3status line with custom
# information. To use it, ensure your ~/.i3status.conf contains this line:
#     output_format = "i3bar"
# in the 'general' section.
# Then, in your ~/.i3/config, use:
#     status_command i3status | ~/i3status/contrib/wrapper.pl
# In the 'bar' section.

use strict;
use warnings;
# You can install the JSON module with 'cpan JSON' or by using your
# distribution’s package management system, for example apt-get install
# libjson-perl on Debian/Ubuntu.
use JSON;

# Don’t buffer any output.
$| = 1;

# Skip the first line which contains the version header.
print scalar <STDIN>;

# The second line contains the start of the infinite array.
print scalar <STDIN>;

open my $bt, '<', '/sys/class/power_supply/battery/uevent';

# Read lines forever, ignore a comma at the beginning if it exists.
while (my ($statusline) = (<STDIN> =~ /^,?(.*)/)) {
    # Decode the JSON-encoded line.
    my $blocks = decode_json($statusline);

    # Prefix our own information (you could also suffix or insert in the
    # middle).
    #@blocks = ({
    #    full_text => 'MPD: not running',
    #    name => 'mpd'
    #}, @blocks);
    
    my $batt = {"name" => "battery","instance" => "/sys/devices/platform/battery/power_supply/battery/uevent","markup" => "none","full_text" => "No battery"};
    my $status = '';
    my $capacity = '';
    for  my $line (<$bt>) {
        if ($line =~ /^POWER_SUPPLY_STATUS=(.*)$/)
        {
            $status = $1;
        }
        if ($line =~ /^POWER_SUPPLY_CAPACITY=(.*)$/)
        {
            $capacity = $1;
        }
    }

    seek $bt, 0, 0;

    if ($capacity) {
        $batt->{full_text} = sprintf('%s %s', $status, $capacity);
    }

    push @$blocks, $batt;

    # Output the line as JSON.
    print encode_json($blocks) . ",\n";
    #print 'ololo'.$statusline."\n";
}

close $bt;

# POWER_SUPPLY_NAME=battery
# POWER_SUPPLY_STATUS=Not charging
# POWER_SUPPLY_HEALTH=Good
# POWER_SUPPLY_PRESENT=1
# POWER_SUPPLY_TECHNOLOGY=Li-ion
# POWER_SUPPLY_CAPACITY=64
# POWER_SUPPLY_BATT_VOL=3964
# POWER_SUPPLY_BATT_TEMP=270
# POWER_SUPPLY_TEMPERATURER=9234
# POWER_SUPPLY_TEMPBATTVOLTAGE=778
# POWER_SUPPLY_INSTATVOLT=3807
# POWER_SUPPLY_BATTERYAVERAGECURRENT=0
# POWER_SUPPLY_BATTERYSENSEVOLTAGE=3964
# POWER_SUPPLY_ISENSEVOLTAGE=3847
# POWER_SUPPLY_CHARGERVOLTAGE=0
# POWER_SUPPLY_STATUS_SMB=3
# POWER_SUPPLY_CAPACITY_SMB=50
# POWER_SUPPLY_PRESENT_SMB=0
# POWER_SUPPLY_ADJUST_POWER=-1

