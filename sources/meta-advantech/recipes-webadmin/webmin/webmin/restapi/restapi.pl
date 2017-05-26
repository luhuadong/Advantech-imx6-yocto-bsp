#!/usr/bin/perl
=head1  A rest api library for perl web server used by Webmin
=cut
$RestfulAPIVersion = "1.0.0";

if (!$ENV{'GATEWAY_INTERFACE'}) {
	$ENV{'WEBMIN_CONFIG'} ||= "/etc/webmin";
	$ENV{'WEBMIN_VAR'} ||= "/var/webmin";
	if ($0 =~ /^(.*\/)[^\/]+$/) {
		chdir($1);
		}
	chop($pwd = `pwd`);
	$0 = "$pwd/restapi.pl";
	$> == 0 || die "restapi must be run as root";
	}
BEGIN { push(@INC, ".."); };
use JSON;
use WebminCore;
&init_config();

&foreign_require("acl", "acl-lib.pl");
&foreign_require("system-status", "system-status-lib.pl");
&foreign_require("proc", "proc-lib.pl");
&foreign_require("net", "net-lib.pl");
&foreign_require("init", "init-lib.pl");
&foreign_require("wise", "wise-lib.pl");

$ProcMgmtRest = "ProcessMgmt";
$SysMgmtRest = "SystemMgmt";
$AccountMgmtRest = "AccountMgmt";
$WSNMgmtRest = "WSNMgmt";
$APIInfoMgmtRest = "APIInfoMgmt";

my %err_1051_json_data;
$err_1051_json_data{result} = {
	ErrorCode => "1051",
	Description => "Input invalid JSON"
};

my %err_1052_json_data;
$err_1052_json_data{result} = {
	ErrorCode => "1052",
	Description => "Input Argument Error"
};

my %err_1101_json_data;
$err_1101_json_data{result} = {
	ErrorCode => "1101",
	Description => "Output invalid JSON"
};

my %err_1151_json_data;
$err_1151_json_data{result} = {
	ErrorCode => "1151",
	Description => "Invalid URL"
};

my %err_1152_json_data;
$err_1152_json_data{result} = {
	ErrorCode => "1152",
	Description => "Invalid Method"
};

my %err_1153_json_data;
$err_1153_json_data{result} = {
	ErrorCode => "1153",
	Description => "Read Only"
};

# is_apimux_installed()
sub is_apimux_installed
{
    if( -r "/usr/bin/apimuxcli" ) {
        return 1;
    } else {
        return 0;
    }
}


=head2 check_hwaddr(mac)

Check MAC address is properly formatted, returning 1 if so or 0 if not.

=cut

sub check_hwaddr
{
	return $_[0] =~ /^([0-9a-f]{2}([:-]|$)){6}$/i;
}

sub wsn_apimux
{
	local $method = $_[0];
	local $uri = $_[1];
	local $content = $_[2];
	local $output;
	my $json_obj = JSON->new;

	if(&is_apimux_installed()) {
		#print DEBUG "wsn_apimux : apimux $method $uri $content\n";
		$output = `cd /usr/bin/; apimuxcli $method $uri $content`;
		#print DEBUG "wsn_apimux : $output\n";
		#$output = substr($output, index($output,"{ \"StatusCode\""));
		$output = substr($output, index($output,"\"StatusCode\""));
		$output = "{ ".$output;
		#print DEBUG "wsn_apimux x: $output\n";
		$output = substr($output, 0, index($output,"eoj"));
		chomp($output);
	} else {
		$output = $json_obj->pretty->encode(\%err_1151_json_data);
	}

	return $output;
}

=head2 handle_restapi(method, posted_data, uri)

=cut

sub handle_restapi
{
	my $Method = $_[0];
	my $PostData = $_[1]; # posted_data
	my $Uri = $_[2];
	my $Out;
	my %json_data;
	my $json_obj = JSON->new;
	my @wsn_data;

	#print DEBUG "handle_restapi : PostData=$PostData Uri=$Uri\n";

	my ($NOUSE, $BN, $N, $SN, $INVALID) = split(/\//, $Uri);
	$Uri =~ s/^\///;
	#print DEBUG "handle_restapi : BN=$BN N=$N Uri=$Uri\n";

	if($BN eq $SysMgmtRest) {
		$Out = &handle_restapi_sysmgmt($Method, $PostData, $Uri);
	} elsif($BN eq $AccountMgmtRest) {
		$Out = &handle_restapi_aclmgmt($Method, $PostData, $Uri);
		&reload_miniserv();
	} elsif($BN eq $ProcMgmtRest) {
		$Out = &handle_restapi_procmgmt($Method, $PostData, $Uri);
	} elsif($BN eq $WSNMgmtRest) {
		$Uri =~ s/^$BN\///;
		$Out = &handle_restapi_wsnmgmt($Method, $PostData, $Uri);
	} elsif($BN eq $APIInfoMgmtRest && !$N) {
		$Out = &handle_restapi_APIInfomgmt($Method);
	} else {
		$Out = $json_obj->pretty->encode(\%err_1151_json_data);
	}

	#print DEBUG "handle_restapi out: $Out\n";

    return $Out;
}

=head2 handle_restapi_wsnmgmt(Method, PostData, N)

=cut

sub handle_restapi_wsnmgmt
{
	my $Out;
	my $Method = $_[0];
	my $PostData = $_[1];
	my $Resource = $_[2];
	my %json_data;
	my $json_obj = JSON->new;
	my $decoded_json;

	#my ($N, $SN) = split(/\//, $Resource);
	#print DEBUG "handle_restapi_wsnmgmt: before $Resource\n";
	#$Resource =~ s/^\///;
	#print DEBUG "handle_restapi_wsnmgmt:$Resource\n";

	if ($PostData) { 
		eval {
			$decoded_json = decode_json($PostData);
			1;
		} or do {
			return $json_obj->pretty->encode(\%err_1051_json_data);
		};
	}

	if ($Method eq "PUT") { 
		#print DEBUG "handle_restapi_wsnmgmt PUT\n";
		#if($Resource eq "Setting") {
		#}
		#elsif($Resource eq "System") {
		#}
		#else {
			$output = wsn_apimux("PUT", $Resource, $PostData);
		#$isize = length($output);
		#print DEBUG "handle_restapi_wsnmgmt output: $output ($isize)\n";
			if ($output) { 
				eval {
					$decoded_json = decode_json($output);
					1;
				} or do {
					return $json_obj->pretty->encode(\%err_1101_json_data);
				};
			}
			else {
				return $json_obj->pretty->encode(\%err_1052_json_data);
			}
			if($decoded_json->{'StatusCode'} == 200) {
				$json_data{result} = "true";
			}
			elsif($decoded_json->{'StatusCode'} == 400) {
				return $json_obj->pretty->encode(\%err_1052_json_data);
			}
			elsif($decoded_json->{'StatusCode'} == 404) {
				return $json_obj->pretty->encode(\%err_1151_json_data);
			}
			elsif($decoded_json->{'StatusCode'} == 405) {
				return $json_obj->pretty->encode(\%err_1153_json_data);
			}
			elsif($decoded_json->{'StatusCode'} == 500) {
				return $json_obj->pretty->encode(\%err_1151_json_data);
			}
			else {
				$json_data{result} = $decoded_json;
			}
		#}
	}
	elsif ($Method eq "GET") {
		#print DEBUG "handle_restapi_wsnmgmt GET\n";
		if($Resource eq "Setting") {
			my $wsn_info;
			%wsnconf = &wise::get_config('wsn_conf');
			$nr = &wise::wsn_nr();
			if($nr > 0) {
				$wsn_info = {
					Interface => 1,
					NetID => $wsnconf{'NetID1'},
					JoinKey => $wsnconf{'JoinKey1'}
				};
				push @wsn_data, $wsn_info;
			}

			if($nr > 1) {
				$wsn_info = {
					Interface => 2,
					NetID => $wsnconf{'NetID2'},
					JoinKey => $wsnconf{'JoinKey2'}
				};
				push @wsn_data, $wsn_info;
			}

			$size = @wsn_data;

			$json_data{result} = {
				item => \@wsn_data,
				totalsize => $size
			};
		}
		else {
			$output = wsn_apimux("GET", $Resource, "");
			#print DEBUG "handle_restapi_wsnmgmt: $output\n";
			if ($output) { 
				eval {
					$decoded_json = decode_json($output);
					1;
				} or do {
					return $json_obj->pretty->encode(\%err_1101_json_data);
				};
			}
			if($decoded_json->{'StatusCode'} == 200) {
				$json_data{result} = $decoded_json->{'Result'};
			}
			elsif($decoded_json->{'StatusCode'} == 404) {
				return $json_obj->pretty->encode(\%err_1151_json_data);
			}
			elsif($decoded_json->{'StatusCode'} == 500) {
				return $json_obj->pretty->encode(\%err_1151_json_data);
			}
			else {
				$json_data{result} = $decoded_json;
			}
		}
		#else {
		#	return $json_obj->pretty->encode(\%err_1151_json_data);
		#}
	}
	elsif ($Method eq "POST") { 
		#print DEBUG "handle_restapi_wsnmgmt POST\n";
		$output = wsn_apimux("POST", $Resource, $PostData);
		#print DEBUG "handle_restapi_wsnmgmt output: $output\n";
		if ($output) { 
			eval {
				$decoded_json = decode_json($output);
				1;
			} or do {
				return $json_obj->pretty->encode(\%err_1101_json_data);
			};
		}
		else {
			return $json_obj->pretty->encode(\%err_1052_json_data);
		}
		if($decoded_json->{'StatusCode'} == 200) {
			$json_data{result} = "true";
		}
		elsif($decoded_json->{'StatusCode'} == 400) {
			return $json_obj->pretty->encode(\%err_1052_json_data);
		}
		elsif($decoded_json->{'StatusCode'} == 404) {
			return $json_obj->pretty->encode(\%err_1151_json_data);
		}
		elsif($decoded_json->{'StatusCode'} == 405) {
			return $json_obj->pretty->encode(\%err_1153_json_data);
		}
		elsif($decoded_json->{'StatusCode'} == 500) {
			return $json_obj->pretty->encode(\%err_1151_json_data);
		}
		else {
			$json_data{result} = $decoded_json;
		}
	}
#	elsif ($Method eq "DELETE") { 
		#print DEBUG "handle_restapi_wsnmgmt DELETE\n";
#		$json_data{result} = "true";
#	}

	if(%json_data) {
		$Out .= $json_obj->pretty->encode(\%json_data);
	}

	return $Out;
}

=head2 handle_restapi_sysmgmt(method, posted_data, action)

=cut

sub handle_restapi_sysmgmt
{
	my $Out;
	my $Method = $_[0];
	my $PostData = $_[1];
	my $Resource = $_[2];
	my %sys_data;
	my %json_data;
	my $json_obj = JSON->new;
	my $decoded_json;

	$Resource =~ s/^$SysMgmtRest//;

	if ($PostData) { 
		eval {
			$decoded_json = decode_json($PostData);
			1;
		} or do {
			return $json_obj->pretty->encode(\%err_1051_json_data);
		};
	}

	#print DEBUG "handle_restapi_sysmgmt : method=$Method, postdata=$PostData, resource=$Resource\n";

	if ($Method eq "PUT") { 
		#print DEBUG "handle_restapi_sysmgmt PUT\n";
		if($Resource eq "/NetworkConfig") {
			my @options;
			$found = 0;
			$err = 0;
			$Iface = $decoded_json->{'iface'};
			$Method = $decoded_json->{'method'};

			my @act = &net::active_interfaces();
			foreach my $ifc (@act) {
				if (&net::iface_type($ifc->{'fullname'}) eq 'Ethernet') {
					if($ifc->{'fullname'} eq $Iface) {
						$found = 1;
					}
				}
			}
			if(!$found) {
				return $json_obj->pretty->encode(\%err_1052_json_data);
			}

			if($Iface && $Method) {
				if($Method eq "static") {
					if(&net::check_ipaddress_any($decoded_json->{'ipaddr'}) && &net::check_ipaddress_any($decoded_json->{'netmask'})) {
						push(@options, ['address', $decoded_json->{'ipaddr'}]);
						push(@options, ['netmask', $decoded_json->{'netmask'}]);
					}
					else {
						$err = 1;
					}
				}
				if($decoded_json->{'broadcast'}) {
					if(&net::check_ipaddress_any($decoded_json->{'broadcast'})) {
						push(@options, ['broadcast', $decoded_json->{'broadcast'}])
					}
					else {
						$err = 1;
					}
				}
				if($decoded_json->{'hwaddr'}) {
					if(check_hwaddr($decoded_json->{'hwaddr'})) {
						push(@options, ['hwaddr', 'ether'.' '.$decoded_json->{'hwaddr'}]);
					}
					else {
						$err = 1;
					}
				}
				if($decoded_json->{'gateway'}) {
					if(&net::check_ipaddress_any($decoded_json->{'gateway'})) {
						push(@options, ['gateway', $decoded_json->{'gateway'}]);
					}
					else {
						$err = 1;
					}
				}
				if($err) {
					return $json_obj->pretty->encode(\%err_1052_json_data);
				}
				else {
					&net::modify_interface_def($Iface, "inet", $Method, \@options, 0);
					$json_data{result} = "true";
				}
			}
			else {
				if($decoded_json->{'hostname'}) {
					&net::save_hostname($decoded_json->{'hostname'});
					$json_data{result} = "true";
				}
				else {
					return $json_obj->pretty->encode(\%err_1052_json_data);
				}
			}
		}
		#elsif($Resource eq "System") {
		#}
		else {
			return $json_obj->pretty->encode(\%err_1151_json_data);
		}
	}
	elsif ($Method eq "GET") {
		#print DEBUG "handle_restapi_sysmgmt GET\n";
		my ($d, $h, $m) = &proc::get_system_uptime();
		my $info = &system_status::get_collected_info();
		my $hostname = &get_system_hostname();
		my $webmin = &get_webmin_version();
		# IP addr
		my $defroute;
		my @act = &net::active_interfaces();
		foreach my $ifc (@act) {
			if (&net::iface_type($ifc->{'fullname'}) eq 'Ethernet') {
				#print DEBUG "x : $ifc->{'fullname'} $ifc->{'address'}\n";
				last;
			}
		}
		my @ifaces = grep { &net::iface_type($_->{'fullname'}) =~ /ether/i }
		  @act;
		@ifaces = ( $act[0] ) if (!@ifaces && @act);
		if (@ifaces) {
			$ifname = $ifaces[0]->{'name'};
			$ipaddr = $ifaces[0]->{'address'};
			$netmask = $ifaces[0]->{'netmask'};
			$ether = $ifaces[0]->{'ether'};
		}
		foreach $route (&net::list_routes()) {
           	if($route->{'dest'} eq "0.0.0.0") {
				$defroute = $route->{'gateway'};
				last;
			}
		}
		my $dns = &net::get_dns_config();
		# CPU usage
		my $cpu_used;
		if ($info->{'cpu'}) {
			@c = @{$info->{'cpu'}};
			$cpu_used = $c[0]+$c[1]+$c[3];
		}
		# CPU Type and cores
    	if ($info->{'load'}) {
        	@c = @{$info->{'load'}};
 	       if (@c > 3) {
    	        $cpu_type = $c[4];
        	}
    	}

		# MEM e VIRT Usage
		my $m_used;
		my $sm_used;
		if ($info->{'mem'}) {
			@m = @{$info->{'mem'}};
			if (@m && $m[0]) {
				$m_size = nice_size( $m[0]*1024 );
				$m_used = ($m[0]-$m[1])/$m[0]*100;
				$m_used = substr $m_used, 0, 2;
			}
			if (@m && $m[2]) {
				$sm_size = nice_size( $m[2]*1024 );
				$sm_used = ($m[2]-$m[3])/$m[2]*100;
				$sm_used = substr $sm_used, 0, 2;
			}
		}
		# HDD Usage
		if ($info->{'disk_total'}) {
			my ($total, $free) = ($info->{'disk_total'}, $info->{'disk_free'});
			$disk_size = nice_size( $info->{'disk_total'} );
			$disk_used = ($total-$free)/$total*100;
			$disk_used = substr $disk_used, 0, 2;
		}
		my $time = localtime(time());

		if(!$Resource) {
			$sys_data{SystemInfo} = {
					os => $info->{'kernel'}->{'os'}." ".$info->{'kernel'}->{'version'},
					arch => $info->{'kernel'}->{'arch'},
					uptime => "$d days, $h hours, $m minutes",
					webmin => $webmin,
					cputype => $cpu_type,
					cpuusage => int($cpu_used),
					memusage => int($m_used),
					memsize => $m_size,
					swapusage => int($sm_used),
					swapsize => $sm_size,
					diskusage => int($disk_used),
					disksize => $disk_size,
					systemtime => $time
			};
			$sys_data{NetworkInfo} = {
					hostname => $hostname,
					iface => $ifname,
					hwaddr => $ether,
					ipaddr => $ipaddr,
					netmask => $netmask,
					gateway => $defroute,
					dns => $dns->{'nameserver'}->[0]
			};
			$json_data{result} = { %sys_data };
		}
		elsif($Resource eq "/SystemInfo") {
			$sys_data{SystemInfo} = {
					os => $info->{'kernel'}->{'os'}." ".$info->{'kernel'}->{'version'},
					arch => $info->{'kernel'}->{'arch'},
					uptime => "$d days, $h hours, $m minutes",
					webmin => $webmin,
					cputype => $cpu_type,
					cpuusage => int($cpu_used),
					memusage => int($m_used),
					memsize => $m_size,
					swapusage => int($sm_used),
					swapsize => $sm_size,
					diskusage => int($disk_used),
					disksize => $disk_size,
					systemtime => $time
			};
			$json_data{result} = { %sys_data };
		}
		elsif($Resource eq "/NetworkInfo") {
			$sys_data{NetworkInfo} = {
					hostname => $hostname,
					iface => $ifname,
					hwaddr => $ether,
					ipaddr => $ipaddr,
					netmask => $netmask,
					gateway => $defroute,
					dns => $dns->{'nameserver'}->[0]
			};
			$json_data{result} = { %sys_data };
		}
		else {
			return $json_obj->pretty->encode(\%err_1151_json_data);
		}
	}
	elsif ($Method eq "POST") { 
		#print DEBUG "handle_restapi_sysmgmt POST\n";
		$Act = $decoded_json->{'action'};
		$Val = $decoded_json->{'value'};
		#print DEBUG "handle_restapi_sysmgmt POST $Act $Val\n";
		if($Resource eq "/Action") {
			if(($Act eq "reboot") && ($Val eq "1")) {
				&init::reboot_system();
				$json_data{result} = "true";
			}
			else {
				return $json_obj->pretty->encode(\%err_1052_json_data);
			}
		}
		else {
			return $json_obj->pretty->encode(\%err_1151_json_data);
		}
	}
#	elsif ($Method eq "DELETE") { 
#		print DEBUG "handle_restapi_sysmgmt DELETE\n";
#		&net::delete_interface_def("eth0:0", 'inet');
#		$json_data{result} = "true";
#	}

	if(%json_data) {
		$Out .= $json_obj->pretty->encode(\%json_data);
		#$Out .= encode_json(\%json_data); # ugly
	}

	return $Out;
}

# Account restapi
sub handle_restapi_aclmgmt
{
	my $Out;
	my $Method = $_[0];
	my $PostData = $_[1];
	my $Resource = $_[2];
	my $rv;
	my @allusers = &acl::list_users();
	my $Name;
	my $Passwd;
	my $decoded_json;
	my @user_data;
	my %json_data;
	my $json_obj = JSON->new;

	$Resource =~ s/^$AccountMgmtRest//;
	my ($NOUSE, $N, $SN, $INVALID) = split(/\//, $Resource);
	#print DEBUG "acl:$Resource-$N-$SN-$INVALID\n";

	if ($INVALID) {
		return $json_obj->pretty->encode(\%err_1151_json_data);
	}

	if ($PostData) { 
		#print DEBUG "handle_restapi_aclmgmt processing posted_data\n";
		eval {
			$decoded_json = decode_json($PostData);
			$Name = $decoded_json->{'username'};
			$Passwd = $decoded_json->{'password'};
			1;
		} or do {
			#my $e = $@;
			#print DEBUG "handle_restapi_aclmgmt: $e\n";
			return $json_obj->pretty->encode(\%err_1051_json_data);
		};
	}

	#print DEBUG "handle_restapi_aclmgmt : method=$Method, postdata=$PostData, resource=$Resource, Name=$Name, Password=$Passwd\n";

	if ($Method eq "PUT") { 
		#print DEBUG "handle_restapi_aclmgmt PUT\n";
		if($N eq "acuntName" && $SN) {
			if ($Name) {
				return $json_obj->pretty->encode(\%err_1052_json_data);
			} else {
				$Name = $SN;
			}
		}
		elsif($N) {
			return $json_obj->pretty->encode(\%err_1151_json_data);
		}
		if ($Name && $Passwd) { 
			my $me;
			foreach my $u (@allusers) {
				if ($u->{'name'} eq $Name) {
					$me = $u;
					last;
				}
			}
			if (!$me) {
				if ($N eq "acuntName") {
					return $json_obj->pretty->encode(\%err_1151_json_data);
				}
				else {
					return $json_obj->pretty->encode(\%err_1052_json_data);
				}
			}
			my $encpass = &acl::encrypt_password($Passwd);
			$me->{'pass'} = $encpass;
			$rv = &acl::modify_user($Name, $me);
			$json_data{result} = "true";
		} else {
			return $json_obj->pretty->encode(\%err_1052_json_data);
		}
	}
	# GET is Retrieve all acccounts info
	elsif ($Method eq "GET") {
		#print DEBUG "handle_restapi_aclmgmt GET\n";
		if (@allusers > 0) {
			my $u;
			my $user_info;
			my $spuser_data;
			foreach $u (@allusers) {
				#print DEBUG "handle_restapi_aclmgmt : user=$u->{'name'}\n";
				$user_info = {
					username => $u->{'name'},
					password => $u->{'pass'},
					lastchange => $u->{'lastchange'}
				};
				if($u->{'name'} eq $SN) {
					$spuser_data = $user_info;
				}
				push @user_data, $user_info;
			}
			$size = @user_data;
			if($N eq "acuntName" && $SN) {
				if ($spuser_data) {
					$json_data{result} = {
						item => $spuser_data
					};
				} else {
					return $json_obj->pretty->encode(\%err_1151_json_data);
				}
			}
			elsif(!$Resource) {
				$json_data{result} = {
					item => \@user_data,
					totalsize => $size
				};
			} else {
				return $json_obj->pretty->encode(\%err_1151_json_data);
			}
		}
	}
	else {
		return $json_obj->pretty->encode(\%err_1152_json_data);
	}
=head2
	# POST is add account info
	elsif ($Method eq "POST" && $Name) { 
		print DEBUG "handle_restapi_aclmgmt POST\n";
		my $me;
		foreach my $u (@allusers) {
			if ($u->{'name'} eq $Name) {
				$me = $u;
			}
		}
		if ($me) {
			print DEBUG "A user named $Name already exists\n";
			return $Out;
		}
		my $encpass = &acl::encrypt_password($Passwd);
		$user = { 'name' => $Name,
			'pass_def' => 0,
			'cert_def' => 1,
			'lang_def' => 1,
			'lang' => "en",
			'notabs' => 0,
			'theme_def' => 1,
			'logouttime_def' => 1,
			'minsize_def' => 1,
			'ipmode' => 0,
			'days_def' => 1,
			'hours_def' => 1,
			'lastchange' => time(),
			'pass' => $encpass };
		$rv = &acl::create_user($user);
		$json_data{result} = {
			name => $user->{'name'},
			lastchange => $user->{'lastchange'}
		};
	}
	elsif ($Method eq "DELETE" && $Name) { 
		print DEBUG "handle_restapi_aclmgmt DELETE\n";
		$rv = &acl::delete_user($Name);
		$json_data{result} = "true";
	}
=cut

	if(%json_data) {
		$Out .= $json_obj->pretty->encode(\%json_data);
	}
	
	return $Out;
}

sub handle_restapi_procmgmt
{
	my $Out;
	my $Method = $_[0];
	my $PostData = $_[1];
	my $Resource = $_[2];
	my %json_data;
	my $json_obj = JSON->new;
	my $decoded_json;
	my @daemon_data;

	$Resource =~ s/^$ProcMgmtRest//;

	if ($PostData) { 
		eval {
			$decoded_json = decode_json($PostData);
			1;
		} or do {
			return $json_obj->pretty->encode(\%err_1051_json_data);
		};
	}

	if ($Method eq "GET") { 
		#print DEBUG "handle_restapi_procmgmt GET $Resource\n";
		@boot = &init::get_inittab_runlevel();
		$currlevel = $boot[0];
		@iacts = &init::list_actions();
		if($Resource eq "/Service") {
			foreach $a (@iacts) {
				@ac = split(/\s+/, $a);
				$nodemap{$ac[1]} = $ac[0];
				push(@acts, $ac[0]);
			}
			for($i=0; $i<@acts; $i++) {
				$daemon_info = {
					name => $acts[$i],
					order => 0,
					onboot => 0 
				};
				foreach $s (&init::action_levels('S', $acts[$i])) {
					local ($l, $p) = split(/\s+/, $s);
					local ($lvl) = (&indexof($l, @boot) >= 0);
					local %daemon;
					if ($lvl && $config{'daemons_dir'} &&
			    		&read_env_file("$config{'daemons_dir'}/$acts[$i]",
							   \%daemon)) {
						$lvl = lc($daemon{'ONBOOT'}) eq 'yes' ? 1 : 0;
					}

					if ($currlevel == $l) {
						$daemon_info->{order} = int($p);
						$daemon_info->{onboot} = int($lvl);
					}
				}
				push @daemon_data, $daemon_info;
			}
			$size = @daemon_data;
			$json_data{result} = {
				service => \@daemon_data,
				total => $size
			};
		}
		else {
			my ($NOUSE, $N, $SN, $INVALID) = split(/\//, $Resource);
			if($N eq "Service" && $SN) {
				if ($INVALID) {
					return $json_obj->pretty->encode(\%err_1151_json_data);
				}
				foreach $a (@iacts) {
					@ac = split(/\s+/, $a);
					$nodemap{$ac[1]} = $ac[0];
					if($SN eq $ac[0]) {
						$daemon_info = {
							name => $SN,
							order => 0,
							onboot => 0 
						};
						foreach $s (&init::action_levels('S', $SN)) {
							local ($l, $p) = split(/\s+/, $s);
							local ($lvl) = (&indexof($l, @boot) >= 0);
							local %daemon;
							#print DEBUG "$SN: $l $p $lvl \n";
							if ($lvl && $config{'daemons_dir'} &&
			    				&read_env_file("$config{'daemons_dir'}/$acts[$i]",
									   \%daemon)) {
								$lvl = lc($daemon{'ONBOOT'}) eq 'yes' ? 1 : 0;
							}

							if ($currlevel == $l) {
								$daemon_info = {
									name => $SN,
									order => int($p),
									onboot => int($lvl) 
								};
								last;
							}
						}
						$json_data{result} = $daemon_info;
					}
				}
				if(!$daemon_info) {
					return $json_obj->pretty->encode(\%err_1151_json_data);
				}
			} else {
				return $json_obj->pretty->encode(\%err_1151_json_data);
			}
		}
	}
	elsif ($Method eq "PUT") { 
		#print DEBUG "handle_restapi_procmgmt PUT $Resource\n";
		$found = 0;
		@boot = &init::get_inittab_runlevel();
		$currlevel = $boot[0];
		@iacts = &init::list_actions();
		$Name = $decoded_json->{'name'};
		$Order = $decoded_json->{'order'};
		$Onboot = $decoded_json->{'onboot'};
		my ($NOUSE, $N, $SN, $INVALID) = split(/\//, $Resource);
		if($N ne "Service") {
			return $json_obj->pretty->encode(\%err_1151_json_data);
		}
=head2
		foreach $a (@iacts) {
			@ac = split(/\s+/, $a);
			$nodemap{$ac[1]} = $ac[0];
			push(@acts, $ac[0]);
		}
		for($i=0; $i<@acts; $i++) {
				foreach $s (&init::action_levels('S', $acts[$i])) {
					local ($l, $p) = split(/\s+/, $s);
					local ($lvl) = (&indexof($l, @boot) >= 0);
					local %daemon;
					if ($lvl && $config{'daemons_dir'} &&
		    			&read_env_file("$config{'daemons_dir'}/$acts[$i]",
							   \%daemon)) {
						$lvl = lc($daemon{'ONBOOT'}) eq 'yes' ? 1 : 0;
					}

					if ($currlevel == $l) {
						print DEBUG "handle_restapi_procmgmt name:$SN,order:$p,onboot:$lvl\n";
					}
				}
		}
=cut
		if(!$Name) {
			if ($INVALID) {
				return $json_obj->pretty->encode(\%err_1151_json_data);
			}
			if($SN) {
				$Name = $SN;
			}
			else {
				return $json_obj->pretty->encode(\%err_1052_json_data);
			}
		} elsif($Name && $SN) {
			return $json_obj->pretty->encode(\%err_1052_json_data);
		}
		foreach $a (@iacts) {
			@ac = split(/\s+/, $a);
			$nodemap{$ac[1]} = $ac[0];
			if($Name eq $ac[0]) {
				$found = 1;
				last;
			}
		}
		#print DEBUG "handle_restapi_procmgmt $Name, $Order, $Onboot\n";
		if($found) {
			if($Order && $Onboot eq "1") {
				#print DEBUG "handle_restapi_procmgmt x $Onboot\n";
				&init::delete_rl_action($Name, $currlevel, 'S');
				&init::add_rl_action($Name, $currlevel, 'S', $Order);
				$json_data{result} = {
					name => $Name,
					order => int($Order),
					onboot => int($Onboot)
				};
			} elsif($Onboot eq "0") {
				#print DEBUG "handle_restapi_procmgmt y $Onboot\n";
				&init::delete_rl_action($Name, $currlevel, 'S');
				$json_data{result} = {
					name => $Name,
					order => 0,
					onboot => int($Onboot)
				};
			} else {
				return $json_obj->pretty->encode(\%err_1052_json_data);
			}
		}
		elsif($Name) {
			return $json_obj->pretty->encode(\%err_1052_json_data);
		}
		else {
			return $json_obj->pretty->encode(\%err_1151_json_data);
		}
	}
	elsif ($Method eq "POST") { 
		#print DEBUG "handle_restapi_procmgmt POST\n";
		$found = 0;
		@iacts = &init::list_actions();
		$Name = $decoded_json->{'name'};
		$Action = $decoded_json->{'action'};
		my ($NOUSE, $N, $SN, $INVALID) = split(/\//, $Resource);
		if($N ne "Service") {
			return $json_obj->pretty->encode(\%err_1151_json_data);
		}
		if(!$Name) {
			if ($INVALID) {
				return $json_obj->pretty->encode(\%err_1151_json_data);
			}
			if($SN) {
				$Name = $SN;
			}
			else {
				return $json_obj->pretty->encode(\%err_1052_json_data);
			}
		} elsif($Name && $SN) {
			return $json_obj->pretty->encode(\%err_1052_json_data);
		}
		foreach $a (@iacts) {
			@ac = split(/\s+/, $a);
			$nodemap{$ac[1]} = $ac[0];
			if($Name eq $ac[0]) {
				$found = 1;
				last;
			}
		}
		if($found) {
			local ($ok, $out);
			if($Name && $Action eq "start") {
				($ok, $out) = &init::start_action($Name);
			} elsif($Name && $Action eq "stop") {
				($ok, $out) = &init::stop_action($Name);
			} elsif($Name && $Action eq "restart") {
				($ok, $out) = &init::restart_action($Name);
			}
			if($ok) {
				$json_data{result} = "true";
			}
			else {
				return $json_obj->pretty->encode(\%err_1052_json_data);
			}
		}
		else {
			return $json_obj->pretty->encode(\%err_1151_json_data);
		}
	}
	#elsif ($Method eq "DELETE") { 
	#}
	else {
		return $json_obj->pretty->encode(\%err_1152_json_data);
	}

	if(%json_data) {
		$Out .= $json_obj->pretty->encode(\%json_data); }
	
	return $Out;
}

sub handle_restapi_APIInfomgmt
{
	my $Method = $_[0];
	my $Out;
	my %json_data;
	my %mgmt_data;
	my $json_obj = JSON->new;
	my @api_data;

	if($Method eq "GET") {
		push @api_data, $ProcMgmtRest;
		push @api_data, $SysMgmtRest;
		push @api_data, $AccountMgmtRest;
		push @api_data, $WSNMgmtRest;

		$size = @api_data;

		$mgmt_data{Mgmt} = {
			item => \@api_data
		};

		$json_data{result} = {
			%mgmt_data,
			totalsize => $size,
			version => $RestfulAPIVersion
		};
	}
	else {
		return $json_obj->pretty->encode(\%err_1152_json_data);
	}

	if(%json_data) {
		$Out .= $json_obj->pretty->encode(\%json_data);
	}

	return $Out;
}

1;
