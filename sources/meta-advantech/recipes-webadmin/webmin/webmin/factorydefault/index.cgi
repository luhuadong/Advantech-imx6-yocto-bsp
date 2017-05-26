#!/usr/bin/perl

require './factorydefault-lib.pl';

ui_print_header(undef, $module_info{'desc'}, "", undef, 1, 1);

# Build table contents
#print "<form action=\"save.cgi\">\n";
#print "<input type=submit value=\"$text{'save'}\"></form>\n";

print &ui_hr();
print &ui_buttons_start();
print &ui_buttons_row("factorydefault.cgi", $text{'index_factorydef'},
                  $text{'index_factorydefmsg'});
print &ui_buttons_end();
print &ui_hr();


ui_print_footer('/', $text{'index'});
