#!/usr/bin/perl

require './fwupdate-lib.pl';
&ReadParse();

&ui_print_header(undef, $text{'fwupdate_title'}, "");

print "<p>\n";
if ($in{'confirm'}) {
	print "<pre> Warning: Updating firmware may take a few minutes. </pre>\n";
	print "<pre> Please don't turn off the power until the firmware update is finished. </pre>\n";
	print "<pre> Verify the integrity of image ... </pre>\n";
	if (verify_md5sum($in{'imagefile'})) {
		print "<meta http-equiv=\"refresh\" content=\"360\">\n";
		print "<pre> Updating the Firmware ... </pre>\n";
		print "<pre> (When finished, please use default settings to login.) </pre>\n";
		#print "<pre> (When finished, please manually reboot and use default settings to login.) </pre>\n";
		update_firmware($in{'imagefile'});
		#print "<pre> Reboot... </pre>\n";
	} else {
		print "<pre> Checksum not found or mismatch ($in{'imagefile'})</pre>\n";
	}
}
else {
  if ($in{'imgfile'}) {
    print "<center><form action=fwupdate.cgi>\n";
	print "<font color=blue> Current version:", current_fwversion(), "</font><br>\n";
	print "<font color=red> Update  version:", select_fwversion($in{'imgfile'}), "</font><br>\n";
	print "<br>\n";
	print "<font size=+1>",&text('fwupdate_rusure'),"</font><br>\n";
	print "<input size=50 type=text name=imagefile value=/media$in{'imgfile'} readonly><br>\n";
	print "<input type=submit value=\"$text{'fwupdate_ok'}\" name=confirm>\n";
	print "</form></center>\n";
	}
  }
&ui_print_footer("", $text{'index_return'});
