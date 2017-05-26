# factorydefault-lib.pl
# Common functions for factory default module

BEGIN { push(@INC, ".."); };
use WebminCore;
init_config();

# wsn_nr()
sub wsn_nr
{
	local $out;
	&open_execute_command(WSN, "cat /tmp/nrdustwsn" , 1, 1);
	while(<WSN>) {
		$out .= $_;
	}
	local ($nWSN) = split(/\s+/, $out);

	close(WSN);

	return $nWSN;
}

=head2 factorydef_system

Back to Advantech factory default

=cut
sub factorydef_system
{
local $nr = &wsn_nr;
&system_logged("fuser -k /dev/ttyUSB0 >$null_file 2>&1");
&system_logged("fuser -k /dev/ttyUSB1 >$null_file 2>&1");
&system_logged("rm -rf /etc/rc5.d/* >$null_file 2>&1");
&system_logged("rm -rf /etc/webmin/webmincron/crons/* >$null_file 2>&1");
&system_logged("cp -rf /etc/webmin/default-config/* /  >$null_file 2>&1");
&system_logged("/usr/lib/webmin/webmin/changepass.pl /etc/webmin admin admin >$null_file 2>&1");
if($nr > 0) {
&system_logged("/usr/bin/restoredustwsn /etc/wsn.conf 1 /dev/ttyUSB0 >$null_file 2>&1");
sleep(1);
}
if($nr > 1) {
&system_logged("/usr/bin/restoredustwsn /etc/wsn.conf 2 /dev/ttyUSB1 >$null_file 2>&1");
sleep(1);
}
&system_logged("hostname -F /etc/hostname >$null_file 2>&1");
&system_logged("/sbin/reboot >$null_file 2>&1");
}

1;
