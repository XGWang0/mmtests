# ExtractMutilate.pm
package MMTests::ExtractMutilate;
use MMTests::SummariseMultiops;
use VMR::Stat;
our @ISA = qw(MMTests::SummariseMultiops);
use strict;

sub new() {
	my $class = shift;
	my $self = {
		_ModuleName  => "ExtractMutilate",
		_DataType    => DataTypes::DATA_ACTIONS_PER_SECOND,
		_ResultData  => []
	};
	bless $self, $class;
	return $self;
}

sub extractReport() {
	my ($self, $reportDir, $reportName, $profile) = @_;

	my @files = <$reportDir/$profile/mutilate-*-1.log>;
	my @clients;
	foreach my $file (@files) {
		my @split = split /-/, $file;
		$split[-1] =~ s/.log//;
		push @clients, $split[-2];
	}
	@clients = sort { $a <=> $b } @clients;
	$self->{_Operations} = \@clients;

	foreach my $client (@clients) {
		my $iteration = 1;

		my @files = <$reportDir/$profile/mutilate-$client-*>;
		foreach my $file (@files) {
			open(INPUT, $file) || die("Failed to open $file\n");
			while (<INPUT>) {
				next if ($_ !~ /^Total QPS/);
				my @elements = split(/\s+/, $_);
				push @{$self->{_ResultData}}, [ $client, $iteration, $elements[3] ];
			}
			close INPUT;
			$iteration++;
		}
	}
}

1;
