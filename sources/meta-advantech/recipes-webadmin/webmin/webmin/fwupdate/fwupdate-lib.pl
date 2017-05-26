# fwupdat-lib.pl

BEGIN { push(@INC, ".."); };
use WebminCore;
init_config();

sub verify_md5sum {
	local $file = $_[0];
	local $out;
	local $filemd;
	if(-e $file) {
	&open_execute_command(MD5, "md5sum ".join(" ", $file), 1, 1);
	while(<MD5>) {
		$out .= $_;
	}
	local ($md, $fn) = split(/\s+/, $out);
	close(MD5);

	&open_readfile(MD5SUM, "$fn.md5");
	while(<MD5SUM>) {
		$filemd .= $_;
	}
	local ($mmd, $mfn) = split(/\s+/, $filemd);
	close(MD5SUM);

	if ($md ne $mmd) {
		return 0;
		#print "<pre> Checksum failed </pre>\n";
		#print "<pre> filename : $fn </pre>\n";
		#print "<pre> md   : $md </pre>\n";
		#print "<pre> mfilename : $mfn </pre>\n";
		#print "<pre> mmd   : $mmd </pre>\n";
	} else {
		return 1;
	}
	}
	return 0;
}

sub update_firmware {
	local $file = $_[0];
	system("umount /media/mmcblk0p* >/dev/null 2>&1");
	system("echo '#!/bin/sh' > /run/update.sh");
	system("echo '/etc/init.d/saagent stop' >> /run/update.sh");
	system("echo 'init 1' >> /run/update.sh");
	system("echo 'sleep 3' >> /run/update.sh");
	system("echo 'mount -o remount,ro /' >> /run/update.sh");
	system("echo 'wdctl -s 3' >> /run/update.sh");
	#system("echo 'while true; do sleep 1;done' >> /run/update.sh"); # for debug
	if($file =~ /\.gz$/i) {
		system("echo 'zcat $file > /dev/mmcblk0' >> /run/update.sh");
	} else {
		system("echo 'cat $file > /dev/mmcblk0' >> /run/update.sh");
	}
	system("echo 'echo 1 > /dev/watchdog' >> /run/update.sh");
	system("chmod +x /run/update.sh");
	system("exec /run/update.sh >/dev/null 2>&1");
}

sub current_fwversion {
	$ver = `uname -r`;
	local @ips = split(/_/, $ver);
	if (!$ips[2]) {
		return "Unknow";
	}
	return $ips[2];
}

sub select_fwversion {
	local $file = $_[0];
	local @ips = split(/_/, $file);
	local $orig = $ips[0];
	$ips[0] =~ s/.*LI//g;
	if ($ips[0] eq $orig) {
		return "Unknow";
	}
	substr($ips[0],2,0) = '.';
	return $ips[0];
}
