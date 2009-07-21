##################################################
# Test for xmlrpc call functions in Bugzilla.pm  #
##################################################

use strict;
use warnings;
use lib qw(lib);
use Test::More tests => 14;
use QA::Util;
my ($rpc, $config) = get_xmlrpc_client();

use constant DATETIME_REGEX => qr/^\d{8}T\d\d:\d\d:\d\d$/;

my $vers_call = xmlrpc_call_success($rpc, 'Bugzilla.version');
my $version = $vers_call->result->{version};
ok($version, "Bugzilla.version returns $version");

my $tz_call = xmlrpc_call_success($rpc, 'Bugzilla.timezone');
my $tz = $tz_call->result->{timezone};
ok($tz, "Bugzilla.timezone retuns $tz");

my $ext_call = xmlrpc_call_success($rpc, 'Bugzilla.extensions');
my $extensions = $ext_call->result->{extensions};
isa_ok($extensions, 'HASH', 'extensions');
is(scalar keys %$extensions, 0, 'No extensions returned');

my $time_call = xmlrpc_call_success($rpc, 'Bugzilla.time');
my $time_result = $time_call->result;
foreach my $type (qw(db_time web_time web_time_utc)) {
    cmp_ok($time_result->{$type}, '=~', DATETIME_REGEX, 
           "Bugzilla.time returns a datetime for $type");
}
cmp_ok($time_result->{tz_offset}, '=~', qr/^(?:\+|-)\d{4}$/,
       "Bugzilla.time's tz_offset is in the right format");
cmp_ok($time_result->{tz_short_name}, '=~', qr/^[A-Z]{3,4}/,
       "Bugzilla.time's tz_short_name is in the right format");
cmp_ok($time_result->{tz_name}, '=~', qr{^(?:(?:\w+/\w+)|(?:UTC))$},
       "Bugzilla.time's tz_name is in the right format");
