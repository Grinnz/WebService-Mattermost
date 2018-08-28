package WebService::Mattermost::API::View::Role::BelongingToTeam;

use Moo::Role;
use Types::Standard qw(InstanceOf Maybe Str);

use WebService::Mattermost::Helper::Alias 'view';

requires 'raw_data';

################################################################################

has team_id => (is => 'ro', isa => Maybe[Str],                  lazy => 1, builder => 1);
#has team => (is => 'ro', isa => Maybe[InstanceOf[view 'Team']], lazy => 1, builder => 1);

################################################################################

sub _build_team_id {
    my $self = shift;

    return $self->raw_data->{team_id};
}

sub _build_team {
    # TODO
}

################################################################################

1;
__END__

=head1 NAME

WebService::Mattermost::API::View::Role::BelongingToTeam

=head1 DESCRIPTION

Link a view object to its creator.

=head2 ATTRIBUTES

=over 4

=item C<team_id>

The creator's string ID.

=item C<team>

In progress - linked C<WebService::Mattermost::API::View::Team> object.

=back

=head1 AUTHOR

Mike Jones L<email:mike@netsplit.org.uk>

