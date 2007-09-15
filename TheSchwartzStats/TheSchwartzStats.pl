# TheSchwartzStats
#
# $Id$
#
# This software is provided as-is. You may use it for commercial or 
# personal use. If you distribute it, please keep this notice intact.
#
# Copyright (c) 2007 Hirotaka Ogawa

package MT::Plugin::TheSchwartzStats;
use strict;
use base qw(MT::Plugin);

use MT;

our $VERSION = '0.01';

my $plugin = __PACKAGE__->new({
    id          => 'theschwartz_stats',
    name        => 'TheSchwartzStats',
    description => q(<MT_TRANS phrase="Dashboard widget for showing TheSchwartz stats.">),
    doc_link    => 'http://code.as-is.net/wiki/TheSchwartzStats',
    author_name => 'Hirotaka Ogawa',
    author_link => 'http://as-is.net/blog/',
    version     => $VERSION,
    l10n_class  => 'TheSchwartzStats::L10N',
});
MT->add_plugin($plugin);

sub init_registry {
    my $plugin = shift;
    $plugin->registry({
	applications => {
	    cms => {
		widgets => {
		    TheSchwartzStats => {
			label    => $plugin->translate('TheSchwartz Stats'),
			template => 'widget.tmpl',
			plugin   => $plugin,
			singular => 1,
			handler  => \&hdlr_widget,
		    }
		}
	    }
	}
    });
}

sub hdlr_widget {
    my $app = shift;
    my ($tmpl, $param) = @_;

    my @data;
    my $task_workers = MT->component('core')->registry('task_workers');
    for my $name (keys %$task_workers) {
	my $worker = $task_workers->{$name};
	my $funcmap = MT->model('ts_funcmap')->load({
	    funcname => $worker->{class}
	}, {
	    unique   => 1
	})
	    or next;
	my $count = MT->model('ts_job')->count({
	    funcid   => $funcmap->funcid
	});

	# I'm not sure, but the following code doesn't work
	#my $count = MT->model('ts_job')->count(undef, {
	#    'join' => MT->model('ts_funcmap')->join_on(
	#	'funcid',
	#	{ funcname => $worker->{class} },
	#	{ unique => 1 }
	#    )
	#});

	push @data, {
	    name  => $name,
	    label => $worker->{label},
	    count => $count,
	};
    }
    $param->{data} = \@data;

    1;
}

1;
