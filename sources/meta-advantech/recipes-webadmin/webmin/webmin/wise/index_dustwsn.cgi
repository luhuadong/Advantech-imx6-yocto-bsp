#!/usr/bin/perl

require './wise-lib.pl';

ui_print_header(undef, $module_info{'desc'}, "", undef, 1, 1);
&index_links("dustwsn");

%wsnconf = &get_config('wsn_conf');
%wiseconf = &get_config('wise_conf');

local $nr = &wsn_nr;
# Build table contents
if($nr > 0) {
print &ui_hr();
print "<form action=\"savewsn.cgi\">\n";
print "<table border width=100%>\n";
print "<tr> <td><table>\n";
print "<tr $tb> <td colspan=4><b>$text{'wsnmanager1'}</b></td> </tr>\n";
print "<tr> <td width=80>",&hlink("<b>$text{'netid1'}</b>","netid1"),"</td>\n";
print "<td><input name=netid1 size=40 maxlength=5 value=\"$wsnconf{'NetID1'}\"> </td></tr>\n";
print "<tr> <td>",&hlink("<b>$text{'joinkey1'}</b>","joinkey1"),"</td>\n";
print "<td><input name=joinkey1 size=40 maxlength=16 value=\"$wsnconf{'JoinKey1'}\"> </td></tr>\n";
if($nr > 1) {
print "<tr $tb> <td colspan=4><b>$text{'wsnmanager2'}</b></td> </tr>\n";
print "<tr> <td width=80>",&hlink("<b>$text{'netid2'}</b>","netid2"),"</td>\n";
print "<td><input name=netid2 size=40 maxlength=5 value=\"$wsnconf{'NetID2'}\"> </td></tr>\n";
print "<tr> <td>",&hlink("<b>$text{'joinkey2'}</b>","joinkey2"),"</td>\n";
print "<td><input name=joinkey2 size=40 maxlength=16 value=\"$wsnconf{'JoinKey2'}\"> </td></tr>\n";
}
print "</table></td></tr></table>\n";
print "<input type=submit value=\"$text{'savewsn'}\" name=savemanager>\n";
print "<input type=submit value=\"$text{'exchangewsn'}\" name=exchange>\n";

print "</form>\n";
print &ui_hr();

if($nr > 0) {
print "<form action=\"listmote.cgi\">\n";
print "<table border width=100%>\n";
print "<tr> <td><table>\n";
print "<tr $tb> <td colspan=2><b>Network Statistics</b></td></tr>\n";
print "<tr>\n";
print "<td><input type=submit value='Network 1 Statistics' name=net1motes></td>\n";
if($nr > 1) {
print "<td><input type=submit value='Network 2 Statistics' name=net2motes></td>\n";
}
print "</tr>\n";
print "</table></td></tr></table>\n";
print "</form>\n";
print &ui_hr();
}

#print "<script language=\"JavaScript\">document.write('<a href=\"http://' + window.location.hostname + ':8080'  +  '\" target=\"_blank\" style=\"color:red\"><button>Advanced Setting</button></a>' );</script>";
#print &ui_hr();
print "<br>\n";
print "<br>\n";
} else {
	print "<pre> WSN module not found. </pre>\n";
}

ui_print_footer('/', $text{'index'});
