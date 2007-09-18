# $Id$
package TheSchwartzStats::CMS;
use strict;
use base 'MT::App';

sub plugin { MT->component('MT::TheSchwartzStats') }
sub id { 'theschwartz_stats_cms' }

sub run_ts_jobs {
    my $app = shift;
    my $user = $app->user;
    return $app->trans_error('Permission Denied.')
	unless $user->is_superuser();

    $| = 1;	# flush open filehandles
    my $pid = fork();
    if (!$pid) {
	close STDIN ; open STDIN , "</dev/null";
	close STDOUT; open STDOUT, ">/dev/null";
	close STDERR; open STDERR, ">/dev/null";

	MT::ObjectDriverFactory->init();
	MT::ObjectDriverFactory->configure();

	require MT::TheSchwartz;
	my $client = MT::TheSchwartz->new;
	$client->work_until_done;

#	require File::Spec;
#	my $runner = File::Spec->catfile($app->mt_dir, 'tools', 'run-periodic-tasks');
#	exec $runner;

	CORE::exit(0);
    }

    MT::ObjectDriverFactory->init();
    MT::ObjectDriverFactory->configure();

    my $plugin = MT::Plugin::TheSchwartzStats->instance;
    my $tmpl = $plugin->load_tmpl('popup.tmpl');
    return $app->build_page($tmpl);
}

1;
