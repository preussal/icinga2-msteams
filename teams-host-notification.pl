#!/usr/bin/perl
#V0.2
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# modified version of nagios-mstreams.pl for icinga2 without env's

use warnings;
use strict;
#use URI::Encode;

use Getopt::Long;
use HTTP::Request::Common qw(POST);
use HTTP::Status qw(is_client_error);
use LWP::UserAgent;
use JSON;

my %event;
my %nagios;
my @sections;
my @actions;
my @targets;
my $webhook;
my $icingaweb2url = "https://monitoring.mydomane.com/icingaweb2";
my $proxyUrl = '';
my %color = ( 'OK' => '008000', 'WARNING' => 'ffff00', 'UNKNOWN' => '808080','CRITICAL' => 'ff0000',
              'UP' => '008000', 'DOWN' => 'ff0000', 'UNREACHABLE' => 'ff8700');
my $webhookuid;
my $longdatetime;
my $servicename;
my $hostname;
my $hostdisplayname;
my $hostoutput;
my $hoststate;
my $notificationtype;
my $servicedisplayname;
my $hostaddress;
my $hostaddress6;
my $notificationauthorname;
my $notificationcomment;

#
# Get command-line options
#
GetOptions (
"p=s" => \$webhook,
"ICINGAWEB2URL:s" => \$icingaweb2url,
"d=s"  => \$longdatetime,
"e:s"  => \$servicename,
"l=s"  => \$hostname,
"n=s"  => \$hostdisplayname,
"o=s"  => \$hostoutput,
"s:s"  => \$hoststate,
"t=s"  => \$notificationtype,
"u=s"  => \$servicedisplayname,
"4=s"  => \$hostaddress,
"6=s"  => \$hostaddress6,
"b=s"  => \$notificationauthorname,
"c=s"  => \$notificationcomment
)
or die("Error in command line arguments\n");

#
# Format message card
#

$event{'title'} = "Icinga2 Notification";
$event{'@type'} = "MessageCard";
$event{'@context'} = "https://schema.org/extensions";

$event{'themecolor'} = $color{"$hoststate"};
$event{'title'} = "$hostdisplayname is $hoststate";
$event{'summary'} = $event{'title'};
my @facts = ({
    'name' => "Host:",
    'value' => "$hostdisplayname"
   },{
    'name' => "Details:",
    'value' => "$hostoutput"
});

my %section;
if (not length($notificationcomment)) {
 %section = ( 'facts' => \@facts );
} else {
 %section = ( 'text' => "Comment: $notificationcomment | Author: $notificationauthorname", 'facts' => \@facts );
}

push(@sections, \%section);
$event{'sections'} = \@sections;

if ($icingaweb2url ne '') {
  #replace / with %2F
  $hostname =~ s/\//%2F/g;
  my $encodedURL =  "$icingaweb2url/monitoring/host/show?host=${hostname}";
  my %target = (
        'os' => 'default',
	'uri' => $encodedURL
  );
  push(@targets, \%target);
  my %link = (
      '@type' => 'OpenUri',
      'name' => 'Open in Icinga2',
      'targets' => \@targets
  );
  push(@actions, \%link);
  $event{'potentialAction'} = \@actions;
}
my $json = encode_json \%event;


#
# Make the request
#

my $ua = LWP::UserAgent->new;
if ($proxyUrl ne '') {
  $ua->proxy(['http','https'], "$proxyUrl");
};
$ua->timeout(15);

my $req = HTTP::Request->new('POST', $webhook);
$req->header('Content-Type' => 'application/json');
$req->content($json);
print($json);

my $s = $req->as_string;
print STDERR "Request:\n$s\n";

my $resp = $ua->request($req);
$s = $resp->as_string;
print STDERR "Response:\n$s\n";
