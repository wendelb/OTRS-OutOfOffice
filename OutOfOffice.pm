package Kernel::System::PostMaster::Filter::OutOfOffice;

use strict;
use warnings;

use Data::Dumper;

our @ObjectDependencies = (
	'Kernel::System::Log',
	'Kernel::System::Ticket'
);

sub new {
	my ( $Type, %Param ) = @_;

	# allocate new hash for object
	my $Self = {};
	bless ($Self, $Type);
	$Self->{Debug} = $Param{Debug} || 0;

	return $Self;
}

sub Run {
	my ( $Self, %Param ) = @_;
	# get config options
	my %Config = ();
	my @Match = ();

	# Start Running
	if ($Self->{Debug}) {
		$Kernel::OM->Get('Kernel::System::Log')->Log(
			Priority => 'notice',
			Message => "Start of Out-of-Office Module",
		);
	}

	# Get Job Configuration
	# We need the configured Match-Array
	if ($Param{JobConfig} && ref($Param{JobConfig}) eq 'HASH') {
		%Config = %{$Param{JobConfig}};

		if ($Config{Match}) {
			@Match = @{$Config{Match}};
		}
		else {
			die("Configuration is missing the 'Match'!");
		}
	}
	else {
		die("Cannot find the JobConfiguration!");
	}

	
	if ($Self->{Debug}) {
		$Kernel::OM->Get('Kernel::System::Log')->Log(
			Priority => 'debug',
			Message => "The following substrings will be matched:\n" . Dumper(@Match)
		);
	}

	# Is there an existing Ticket to the incoming mail?
	if ( !$Param{TicketID} ) {
        # No ticket found -> no Follow-up.
		# No action required!
        return 1;
    }

	# Access Ticket Search Feature
	my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');

	# Get the Ticket matching the incoming mail
	my %Ticket = $TicketObject->TicketGet(
        TicketID => $Param{TicketID},
        UserID => 1
    );

	my $isMatch = 0;
	# Do the comparison case-IN-sensitive
	my $subject = uc($Param{GetParam}->{'Subject'});
	
	# For each entry in the Match-Array check if it is a substring of the Mail Subject
	foreach my $item (@Match) {
		if (index($subject, uc($item)) != -1) {
			if ($Self->{Debug}) {
				$Kernel::OM->Get('Kernel::System::Log')->Log(
					Priority => 'debug',
					Message => sprintf("Found match: %s is substring of %s", $item, $subject)
				);
			}
			$isMatch++;
		}
	}
	
	# There was at least one match
	if ($isMatch > 0) {
        $Param{GetParam}->{'X-OTRS-FollowUp-State'} = $Ticket{State};
    }

	return 1;
}

# Return a truthy value on load (Perl-standard)
1;