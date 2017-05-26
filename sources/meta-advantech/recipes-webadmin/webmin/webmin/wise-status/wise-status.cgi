#!/usr/bin/perl
# Show wise connection status

BEGIN { push(@INC, ".."); };
use WebminCore;
use JSON;

&init_config();
&foreign_require("wise", "wise-lib.pl");
&foreign_require("wisecloud", "wisecloud-lib.pl");

$apimux_client = "apimuxcli";
$cagnet_status_file = "/usr/local/AgentService/agent_status";
$connected_img = "<td><img src=images/conn.png border=0 width=120 height=81 title=\"Connected\"></td>\n";
$disconnected_img = "<td><img src=images/disconn.png border=0 width=120 height=81 title=\"Disconnected\"></td>\n";

# check_apimux_installed()
sub check_apimux_installed
{
    if( -r "/usr/bin/$apimux_client" ) {
        return 1;
    } else {
        return 0;
    }
}

$is_apimux_installed = &check_apimux_installed();

sub check_cagent_active
{
	$output = `ps ax|grep -v grep|grep cagent`;
	if($output) {
		return 1;
	} else {
		return 0;
	}
}
$is_cagent_active = &check_cagent_active();

sub wsn_apimux
{
	local $method = $_[0];
	local $uri = $_[1];
	local $content = $_[2];
	local $output;
	my $json_obj = JSON->new;

	#if(&is_apimux_installed() && &is_cagent_active()) {
	if($is_apimux_installed && $is_cagent_active) {
		$output = `cd /usr/bin/; $apimux_client $method $uri $content`;
		$output = substr($output, index($output,"\"StatusCode\""));
		$output = "{ ".$output;
		$output = substr($output, 0, index($output,"eoj"));
		chomp($output);
	}

	return $output;
}

sub get_wsn_intf_mac
{
	local $output;
	my $decoded_json;

	$output = &wsn_apimux("GET", "IoTGW", "");
	if ($output) { 
		eval {
			$decoded_json = decode_json($output);
			1;
		} or do {
			return $output; 
		};
	}

	if($decoded_json->{'StatusCode'} == 200) {
		return $decoded_json->{'Result'}->{'WSN'}->{'WSN0'}->{'bn'};
	}
}

sub get_wsn_senhublist
{
	local $output;
	my $decoded_json;

	$macaddr = &get_wsn_intf_mac();
	sleep(1);
	$output = &wsn_apimux("GET", "IoTGW/WSN/$macaddr/Info/SenHubList", "");
	if ($output) { 
		eval {
			$decoded_json = decode_json($output);
			1;
		} or do {
			return $output; 
		};
	}

	if($decoded_json->{'StatusCode'} == 200) {
		return $decoded_json->{'Result'}->{'sv'};
	}
}

sub check_cagent_cloud_conn
{
	local $stat = `cat $cagnet_status_file`;
    $stat = substr($stat,0,1);
	local $output = `netstat -an|grep :1883`;
	local @arr = split(' ', $output);
	if($stat eq '1' && $is_cagent_active) {
		return 1;
	# double check
	#} elsif($arr[5] eq "ESTABLISHED") {
	#	return 1;
	} else {
		return 0;
	}
}
$is_cagent_cloud_conn = &check_cagent_cloud_conn();

%wiseconf = &wisecloud::get_config('wise_conf');

&popup_header(undef);
#print "<script language=\"JavaScript\">
#function myrefresh()
#{
#window.location.reload();
#}
#setTimeout('myrefresh()',10000);
#</script>";

$nr = &wise::wsn_nr();
$sensorhub_list = &get_wsn_senhublist;
@sensorhub_arr = split(',', $sensorhub_list);
$sensorhub_nr = @sensorhub_arr;

if($nr > 0) {
=head2
	@net1motes = &wise::list_mote(1, "/dev/ttyUSB0");
	my $net1info = pop @net1motes;
	foreach $pr (@net1motes) {              
        if($pr->{'state'} eq "OPER") {
			$nr_net1motes++;
		}
	}
	if($nr_net1motes > 0) {
		$nr_net1motes--;
	}
=cut
	if($sensorhub_nr < 1) {
		$nr_net1motes = 0;
	} else {
		$nr_net1motes = $sensorhub_nr - 1;
	}
	if($nr > 1) {
=head2
	@net2motes = &wise::list_mote(2, "/dev/ttyUSB1");
	my $net2info = pop @net2motes;
		foreach $pr (@net2motes) {              
        	if($pr->{'state'} eq "OPER") {
				$nr_net2motes++;
			}
		}
		if($nr_net2motes > 0) {
			$nr_net2motes--;
		}
=cut
	$nr_net2motes = 0;
	}
}

print "<center>\n";
# logo
print "<a href=http://www.advantech.com/ target=_new><img src=images/logo.png border=0></a><p>\n";
print "<table><tr>\n";
if($nr > 0) {
	print "<td>\n";
	#print "<a target=right href='wise/listmote.cgi?net1motes=Network 1 Statistics'>\n";
	print "<img src=images/sensorhub.jpg border=0>";
	print "<br><b>Network 1<br>Links:<font size=\"+1\" color=red>$nr_net1motes</font></b>\n";
	#print "</a>\n";
	print "<br>\n";
	if($nr > 1) {
		#print "<a target=right href='wise/listmote.cgi?net2motes=Network 2 Statistics'>\n";
		print "<img src=images/sensorhub.jpg border=0>";
		print "<br><b>Network 2<br>Links:<font color=red>$nr_net2motes</font></b>\n";
		#print "</a>\n";
	}
	print "</td>\n";
	if($nr_net1motes > 0) {
		print $connected_img;
	} else {
		print $disconnected_img;
	}
}
print "<td><a target=right href='wise/index.cgi'>";
print "<img src=images/gateway.png border=0";
if($is_cagent_active) {
	print " title=\"CAgent is running!\">";
} else {
	print " title=\"CAgent is not running!\">";
}
print "</a></td>\n";
if($is_cagent_cloud_conn) {
	print $connected_img;
} else {
	print $disconnected_img;
}
print "<td><a target=right href='wisecloud/index.cgi'>";
print "<img src=images/wise-cloud.gif border=0 title=$wiseconf{'ServerIP'}></a></td>\n";
print "</tr></table>\n";

print "<button onclick=\"location.href='wise-status.cgi'\">Refresh</button>\n";
print "</center>\n";

&popup_footer();
