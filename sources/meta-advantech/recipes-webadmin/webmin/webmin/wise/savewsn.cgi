#!/usr/bin/perl

require './wise-lib.pl';
ReadParse();

&ui_print_header(undef, $text{'index_title'}, "");
print "<p>\n";

local $pid1 = in_use_pid("/dev/ttyUSB0");
local $pid2 = in_use_pid("/dev/ttyUSB1");
if ($pid1 == "" && $pid2 == "") {

if ($in{'netid'} < 0 || $in{'netid1'} > 65534 || $in{'netid2'} < 0 || $in{'netid2'} > 65534) {
print "<pre> Please input Network ID 0~65534 </pre>\n";
} else {
lock_file($config{'wsn_conf'});
open(FILE, "> $config{'wsn_conf'}");
print FILE "[WSNManager]\n";
print FILE "NetID1 = $in{'netid1'}\n";
print FILE "JoinKey1 = $in{'joinkey1'}\n";
print FILE "NetID2 = $in{'netid2'}\n";
print FILE "JoinKey2 = $in{'joinkey2'}\n";
close(FILE);
unlock_file($config{'wsn_conf'});

local $temp = "/tmp/savedustwsn.log";
local $execcmd;
local $rv1;
local $rv2;
local $nr = &wsn_nr;

if ($in{'savemanager'}) {
$execcmd = "/usr/bin/savedustwsn";
print "<pre> Save configuration...</pre>\n";
} else {
$execcmd = "/usr/bin/exchangedustwsn";
print "<pre> Warning: Save&Exchange configuration may take a long time. </pre>\n";
print "<pre> Please wait until the action finished. </pre>\n";
print "<pre> Save&Exchange configuration...</pre>\n";
}
if($nr > 0) {
$rv1 = &system_logged("$execcmd $config{'wsn_conf'} 1 /dev/ttyUSB0 >$temp 2>&1");
if (!$rv1) { 
&system_logged("/usr/bin/resetdustwsn 1 /dev/ttyUSB0 >$temp 2>&1");
}
}
if($nr > 1) {
$rv2 = &system_logged("$execcmd $config{'wsn_conf'} 2 /dev/ttyUSB1 >>$temp 2>&1");
if (!$rv2) { 
&system_logged("/usr/bin/resetdustwsn 2 /dev/ttyUSB1 >$temp 2>&1");
}
}

if($nr > 0) {
if ($in{'savemanager'}) {
	sleep(20);
}
}

local $out = `cat $temp`;
unlink($temp);
if($nr > 1) {
  if ($rv1 || $rv2) { 
    print "<pre> Fail!</pre>\n";
    print "<pre> $out</pre>\n";
  } else { 
    print "<pre> Done!</pre>\n";
  }
} elsif ($nr > 0) { 
  if ($rv1) { 
    print "<pre> Fail!</pre>\n";
    print "<pre> $out</pre>\n";
  } else { 
    print "<pre> Done!</pre>\n";
  }
}
}
} else {
	local $task1 = in_use_task($pid1);
	local $task2 = in_use_task($pid2);
	print "<b>Warning</b>";
	print "<font> - Please go to \"Running Processes\" or \"Bootup and Shutdown\" page to close applications\n";
	if ($pid1) {
		print "\"$task1(PID:$pid1)\" ";
	}
	if ($pid2) {
		print "\"$task2(PID:$pid2)\" ";
	}
    print " before applying settings.</font>\n";
}
&ui_print_footer("", $text{'index_title'});
