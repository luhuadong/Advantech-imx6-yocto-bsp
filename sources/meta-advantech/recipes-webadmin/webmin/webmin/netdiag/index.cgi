#!/usr/bin/perl

require './netdiag-lib.pl';

ui_print_header(undef, $module_info{'desc'}, "", undef, 1, 1);

# Build table contents
print &ui_hr();
print "<form action=\"netdiag.cgi\">\n";
print "<table border width=100%>\n";
print "<tr> <td><table>\n";
print "<tr> <td width=130><b>IP or Domain Name</b></td>\n";
print "<td><input name=destinput size=40 value=\"www.advantech.com.tw\"> </td></tr>\n";
print "</table></td></tr></table>\n";
print "<input type=submit value=\"$text{'pingbtn'}\" name=ping></form>\n";
print &ui_hr();

print "<form action=\"netdiag.cgi\">\n";
print "<table border width=100%>\n";
print "<tr> <td><table>\n";
print "<tr> <td width=130><b>IP or Domain Name</b></td>\n";
print "<td><input name=destinput size=40 value=\"www.advantech.com.tw\"> </td></tr>\n";
print "</table></td></tr></table>\n";
print "<input type=submit value=\"$text{'trbtn'}\" name=troute></form>\n";
print &ui_hr();

print "<form action=\"netdiag.cgi\">\n";
print "<table border width=100%>\n";
print "<tr> <td><table>\n";
print "<tr> <td width=130><b>Domain Name</b></td>\n";
print "<td><input name=destinput size=40 value=\"www.advantech.com.tw\"> </td></tr>\n";
print "</table></td></tr></table>\n";
print "<input type=submit value=\"$text{'nslbtn'}\" name=nslookup></form>\n";
print &ui_hr();

ui_print_footer('/', $text{'index'});
