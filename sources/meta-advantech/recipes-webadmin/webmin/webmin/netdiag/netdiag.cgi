#!/usr/bin/perl
# netdiag.cgi

require './netdiag-lib.pl';
require '../proc/proc-lib.pl';
&ReadParse();

$in{'destinput'} =~ s/\r//g;

if ($in{'ping'}) {
$cmd = "ping -c 5";
} elsif($in{troute}) {
$cmd = "traceroute";
} elsif($in{nslookup}) {
$cmd = "nslookup";
}

if ($cmd) {
	# run and display output..
	&ui_print_unbuffered_header(undef, "Command Output", "");
	print "<p>\n";
	print &text('run_output', "<tt>$in{'cmd'}</tt>"),"<p>\n";
	print "<pre>";
	$got = &safe_process_exec_logged("$cmd $in{destinput}", 0, 0,
					 STDOUT, "", 1);
	if (!$got) { print "<i>$text{'run_none'}</i>\n"; }
	print "</pre>\n";
	&ui_print_footer("", $text{'index'});
}
