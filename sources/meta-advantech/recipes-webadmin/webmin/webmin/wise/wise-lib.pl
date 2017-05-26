# wise-lib.pl
# Common functions for the wise wsn

BEGIN { push(@INC, ".."); };
use WebminCore;
init_config();

sub get_config {
    local $config_file = $_[0];
    local %conf;
    open(FILE, $config{$config_file});
    while(<FILE>) {
    chomp;
    s/#.*//;
    s/^\s+//;
    s/\s+$//;
    s/^\[.*$//;
    next unless length;
    my ($var, $value) = split(/\s*=\s*/, $_, 2);
    $conf{$var} = $value;
    }
    close(FILE);
    return %conf;
}

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

# list_mote(intf, port)
sub list_mote
{
local $intf = $_[0];
local $port = $_[1];
local($line, $dummy, @w, $i, @plist);
local @cols = ( "mac","moteid","state","routing","reliability","latency" );
open(LISTMOTE, "listmote $intf $port |");
for($i=0; $line=<LISTMOTE>; $i++) {
        chop($line);
        $line =~ s/^\s+//g;
        @w = split(/\s+/, $line);
        $plist[$i]->{"mac"} = $w[0];
        $plist[$i]->{"moteid"} = $w[1];
        $plist[$i]->{"state"} = $w[2];
        if($w[3]) {
        	$plist[$i]->{"routing"} = "YES";
    	} else {
        	$plist[$i]->{"routing"} = "NO";
		}
        $plist[$i]->{"reliability"} = $w[4];
        $plist[$i]->{"latency"} = $w[5];
        }
close(LISTMOTE);
return @plist;
}

# in_use_pid()
sub in_use_pid()
{
	local $intf = $_[0];
	local $out;
	&open_execute_command(USED, "fuser $intf" , 1, 1);
	while(<USED>) {
		$out .= $_;
	}
	local ($PID) = split(/\s+/, $out);

	close(USED);

	return $PID;

}

sub in_use_task()
{
	local $pid = $_[0];
	local $out;
	&open_execute_command(COMM, "cat /proc/$pid/comm" , 1, 1);
	while(<COMM>) {
		$out .= $_;
	}
	local ($TASK) = split(/\s+/, $out);

	close(COMM);

	return $TASK;

}

sub index_links
{
local(%linkname, $l);
print "<b>$text{'index_display'} : </b>\n";
local @links;
#foreach $l ("dustwsn", "wifi", "ble") {
foreach $l ("dustwsn") {
        local $link;
        if ($l ne $_[0]) { $link .= "<a href=index_$l.cgi>"; }
        else { $link .= "<b>"; }
        $link .= $text{"index_$l"};
        if ($l ne $_[0]) { $link .= "</a>"; }
        else { $link .= "</b>"; }
        push(@links, $link);
        }
print &ui_links_row(\@links);
print "<p>\n";
}

1;
