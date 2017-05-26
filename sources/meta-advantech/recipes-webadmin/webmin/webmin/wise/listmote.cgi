#!/usr/bin/perl

require './wise-lib.pl';
ReadParse();

if ($in{'net1motes'}) {
&ui_print_header(undef, "WSN $in{'net1motes'}", "");
} else {
&ui_print_header(undef, "WSN $in{'net2motes'}", "");
}
print "<p>\n";

local $pid1 = in_use_pid("/dev/ttyUSB0");
local $pid2 = in_use_pid("/dev/ttyUSB1");
if ($pid1 == "" && $pid2 == "") {

if ($in{'net1motes'}) {
	@motes = &list_mote(1, "/dev/ttyUSB0");
} else {
	@motes = &list_mote(2, "/dev/ttyUSB1");
}

my $netinfo = pop @motes;

if ($netinfo->{'mac'} ne "ERROR:") { 
print "<table border width=30%>\n";    
print "<tr> <td>NetReliability</td>\n";  
print "<td>$netinfo->{'mac'} %</td></tr>\n";
print "<tr> <td>NetPathStability</td>\n";                    
print "<td>$netinfo->{'moteid'} %</td></tr>\n";
print "<tr> <td>NetLatency</td>\n";                    
print "<td>$netinfo->{'state'} (msec)</td></tr>\n";
print "</table>\n";
print "<p>\n";
}

print &ui_columns_start([ 'MAC address',
                          'MoteID',
                          'State',
                          'Routing',
                          'Reliability (%)',
                          'Latency (msec)' ], 100);

        foreach $pr (@motes) {              
        local @cols;          
        push(@cols, $pr->{'mac'});   
        push(@cols, $pr->{'moteid'});
        push(@cols, $pr->{'state'}); 
        push(@cols, $pr->{'routing'});
        push(@cols, $pr->{'reliability'});
        push(@cols, $pr->{'latency'});
        print &ui_columns_row(\@cols);
        $inlist{$pr->{'mac'}}++;      
        } 

print &ui_columns_end();                      

} else {
	local $task1 = in_use_task($pid1);
	local $task2 = in_use_task($pid2);
	print "<b>Warning</b>";
	print "<font> - Please go to \"Running Processes\" or \"Bootup and Shutdown\" page to close applications\n";
	if ($pid1) {
		print "$task1(PID:$pid1) ";
	}
	if ($pid2) {
		print "$task2(PID:$pid2) ";
	}
    print " before applying settings.</font>\n";
}
&ui_print_footer("", $text{'index_title'});
