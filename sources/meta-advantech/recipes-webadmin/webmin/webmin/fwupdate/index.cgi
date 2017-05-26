#!/usr/bin/perl

require './fwupdate-lib.pl';

ui_print_header(undef, $module_info{'desc'}, "", undef, 1, 1);

print &ui_hr();

print "<form action=\"fwupdate.cgi\">\n";
print "<table border width=100%>\n";
print "<tr> <td><table>\n";
print "<tr $tb> <td colspan=2><b>Firmware Update</b></td> </tr>\n";
print "<tr><td>Please select firmware image to Update</td>\n";
print "<td><input name=imgfile size=50> ",&file_chooser_button("imgfile", 0, 0, "/media"),"</td></tr>\n";
print "</table>\n";
print "</td></tr></table>\n";
print "<br>\n";
print "<input type=submit value=\"Update\"></form>\n";

print "<p>\n";
print "<b>Warning</b><font> - After firmware upgrade, the system will restore its default setting, the IP address will return to 192.168.0.1.</font>\n";

ui_print_footer('/', $text{'index'});
