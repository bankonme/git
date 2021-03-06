#!/usr/bin/perl
use strict;
use warnings;

print <<"EOT";
/* Automatically generated by $0 */

struct cmdname_help {
	char name[16];
	char help[80];
	unsigned char group;
};

static char *common_cmd_groups[] = {
EOT

my $n = 0;
my %grp;
while (<>) {
	last if /^### command list/;
	next if (1../^### common groups/) || /^#/ || /^\s*$/;
	chop;
	my ($k, $v) = split ' ', $_, 2;
	$grp{$k} = $n++;
	print "\tN_(\"$v\"),\n";
}

print "};\n\nstatic struct cmdname_help common_cmds[] = {\n";

while (<>) {
	next if /^#/ || /^\s*$/;
	my @tags = split;
	my $cmd = shift @tags;
	for my $t (@tags) {
		if (exists $grp{$t}) {
			my $s;
			open my $f, '<', "Documentation/$cmd.txt" or die;
			while (<$f>) {
				($s) = /^$cmd - (.+)$/;
				last if $s;
			}
			close $f;
			$cmd =~ s/^git-//;
			print "\t{\"$cmd\", N_(\"$s\"), $grp{$t}},\n";
			last;
		}
	}
}

print "};\n";
