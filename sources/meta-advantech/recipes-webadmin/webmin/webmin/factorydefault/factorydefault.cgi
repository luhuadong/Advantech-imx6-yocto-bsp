#!/usr/bin/perl
# factorydefault.cgi

require './factorydefault-lib.pl';
&ReadParse();
&ui_print_header(undef, $text{'factorydef_title'}, "");
print "<p>\n";
if ($in{'confirm'}) {
    print "<font size=+1>",&text('factorydef_exec'),"</font>\n";
    &factorydef_system();
    print "<font size=+1>Done. </font><p><font size=+1>Rebooting...</font>\n";
    }
else {
    print "<font size=+1>",&text('factorydef_rusure'),"</font>\n";
    print "<center><form action=factorydefault.cgi>\n";
    print "<input type=submit value=\"$text{'factorydef_ok'}\" name=confirm>\n";
    print "</form></center>\n";
    }
&ui_print_footer("", $text{'index_return'});
