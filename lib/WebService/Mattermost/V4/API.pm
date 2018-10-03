package WebService::Mattermost::V4::API;

use Moo;
use MooX::HandlesVia;
use Types::Standard qw(ArrayRef Bool InstanceOf Str);

use WebService::Mattermost::V4::API::Resource::Brand;
use WebService::Mattermost::V4::API::Resource::Channel;
use WebService::Mattermost::V4::API::Resource::Channel::Member;
use WebService::Mattermost::V4::API::Resource::Channels;
use WebService::Mattermost::V4::API::Resource::Cluster;
use WebService::Mattermost::V4::API::Resource::Compliance;
use WebService::Mattermost::V4::API::Resource::DataRetention;
use WebService::Mattermost::V4::API::Resource::ElasticSearch;
use WebService::Mattermost::V4::API::Resource::Emoji;
use WebService::Mattermost::V4::API::Resource::File;
use WebService::Mattermost::V4::API::Resource::Files;
use WebService::Mattermost::V4::API::Resource::Jobs;
use WebService::Mattermost::V4::API::Resource::LDAP;
use WebService::Mattermost::V4::API::Resource::OAuth;
use WebService::Mattermost::V4::API::Resource::Plugin;
use WebService::Mattermost::V4::API::Resource::Plugins;
use WebService::Mattermost::V4::API::Resource::Post;
use WebService::Mattermost::V4::API::Resource::Posts;
use WebService::Mattermost::V4::API::Resource::Reactions;
use WebService::Mattermost::V4::API::Resource::Roles;
use WebService::Mattermost::V4::API::Resource::SAML;
use WebService::Mattermost::V4::API::Resource::Schemes;
use WebService::Mattermost::V4::API::Resource::System;
use WebService::Mattermost::V4::API::Resource::Team;
use WebService::Mattermost::V4::API::Resource::Teams;
use WebService::Mattermost::V4::API::Resource::User;
use WebService::Mattermost::V4::API::Resource::Users;
use WebService::Mattermost::V4::API::Resource::Webhooks;
use WebService::Mattermost::Helper::Alias 'v4';

################################################################################

has auth_token => (is => 'ro', isa => Str, required => 1);
has base_url   => (is => 'ro', isa => Str, required => 1);

has authenticate => (is => 'ro', isa => Bool,     default => 0);
has resources    => (is => 'rw', isa => ArrayRef, default => sub { [] },
    handles_via => 'Array',
    handles     => {
        add_resource => 'push',
    });

has brand          => (is => 'ro', isa => InstanceOf[v4 'Brand'],           lazy => 1, builder => 1);
has channels       => (is => 'ro', isa => InstanceOf[v4 'Channels'],        lazy => 1, builder => 1);
has channel        => (is => 'ro', isa => InstanceOf[v4 'Channel'],         lazy => 1, builder => 1);
has channel_member => (is => 'ro', isa => InstanceOf[v4 'Channel::Member'], lazy => 1, builder => 1);
has cluster        => (is => 'ro', isa => InstanceOf[v4 'Cluster'],         lazy => 1, builder => 1);
has compliance     => (is => 'ro', isa => InstanceOf[v4 'Compliance'],      lazy => 1, builder => 1);
has data_retention => (is => 'ro', isa => InstanceOf[v4 'DataRetention'],   lazy => 1, builder => 1);
has elasticsearch  => (is => 'ro', isa => InstanceOf[v4 'ElasticSearch'],   lazy => 1, builder => 1);
has emoji          => (is => 'ro', isa => InstanceOf[v4 'Emoji'],           lazy => 1, builder => 1);
has file           => (is => 'ro', isa => InstanceOf[v4 'File'],            lazy => 1, builder => 1);
has files          => (is => 'ro', isa => InstanceOf[v4 'Files'],           lazy => 1, builder => 1);
has jobs           => (is => 'ro', isa => InstanceOf[v4 'Jobs'],            lazy => 1, builder => 1);
has ldap           => (is => 'ro', isa => InstanceOf[v4 'LDAP'],            lazy => 1, builder => 1);
has oauth          => (is => 'ro', isa => InstanceOf[v4 'OAuth'],           lazy => 1, builder => 1);
has plugin         => (is => 'ro', isa => InstanceOf[v4 'Plugin'],          lazy => 1, builder => 1);
has plugins        => (is => 'ro', isa => InstanceOf[v4 'Plugins'],         lazy => 1, builder => 1);
has post           => (is => 'ro', isa => InstanceOf[v4 'Post'],            lazy => 1, builder => 1);
has posts          => (is => 'ro', isa => InstanceOf[v4 'Posts'],           lazy => 1, builder => 1);
has reactions      => (is => 'ro', isa => InstanceOf[v4 'Reactions'],       lazy => 1, builder => 1);
has roles          => (is => 'ro', isa => InstanceOf[v4 'Roles'],           lazy => 1, builder => 1);
has saml           => (is => 'ro', isa => InstanceOf[v4 'SAML'],            lazy => 1, builder => 1);
has schemes        => (is => 'ro', isa => InstanceOf[v4 'Schemes'],         lazy => 1, builder => 1);
has system         => (is => 'ro', isa => InstanceOf[v4 'System'],          lazy => 1, builder => 1);
has team           => (is => 'ro', isa => InstanceOf[v4 'Team'],            lazy => 1, builder => 1);
has teams          => (is => 'ro', isa => InstanceOf[v4 'Teams'],           lazy => 1, builder => 1);
has user           => (is => 'ro', isa => InstanceOf[v4 'User'],            lazy => 1, builder => 1);
has users          => (is => 'ro', isa => InstanceOf[v4 'Users'],           lazy => 1, builder => 1);
has webhooks       => (is => 'ro', isa => InstanceOf[v4 'Webhooks'],        lazy => 1, builder => 1);

################################################################################

sub BUILD {
    my $self = shift;

    foreach my $name (sort $self->meta->get_attribute_list) {
        my $attr = $self->meta->get_attribute($name);

        if ($attr->has_builder) {
            my $cref = $self->can($name);

            $self->$cref;
        }
    }

    return 1;
}

################################################################################

sub _new_resource {
    my $self     = shift;
    my $name     = shift;
    my $alt_name = shift || lc $name;

    my $resource = v4($name)->new({
        auth_token => $self->auth_token,
        base_url   => $self->base_url,
        resource   => $alt_name,
    });

    $self->add_resource($resource);

    return $resource;
}

################################################################################

# The optional second parameter in some of these builders sets the "resource
# name", i.e. DataRetention's base resource is "data_retention", not
# "dataretention".

sub _build_brand          { shift->_new_resource('Brand')                           }
sub _build_channel        { shift->_new_resource('Channel', 'channels')             }
sub _build_channel_member { shift->_new_resource('Channel::Member', 'channels')     }
sub _build_channels       { shift->_new_resource('Channels')                        }
sub _build_cluster        { shift->_new_resource('Cluster')                         }
sub _build_compliance     { shift->_new_resource('Compliance')                      }
sub _build_data_retention { shift->_new_resource('DataRetention', 'data_retention') }
sub _build_elasticsearch  { shift->_new_resource('ElasticSearch')                   }
sub _build_emoji          { shift->_new_resource('Emoji')                           }
sub _build_files          { shift->_new_resource('Files', 'files')                  }
sub _build_file           { shift->_new_resource('File')                            }
sub _build_jobs           { shift->_new_resource('Jobs')                            }
sub _build_ldap           { shift->_new_resource('LDAP')                            }
sub _build_oauth          { shift->_new_resource('OAuth')                           }
sub _build_plugin         { shift->_new_resource('Plugin', 'plugins')               }
sub _build_plugins        { shift->_new_resource('Plugins')                         }
sub _build_post           { shift->_new_resource('Post', 'posts')                   }
sub _build_posts          { shift->_new_resource('Posts')                           }
sub _build_reactions      { shift->_new_resource('Reactions')                       }
sub _build_roles          { shift->_new_resource('Roles')                           }
sub _build_saml           { shift->_new_resource('SAML')                            }
sub _build_schemes        { shift->_new_resource('Schemes')                         }
sub _build_system         { shift->_new_resource('System')                          }
sub _build_team           { shift->_new_resource('Team', 'teams')                   }
sub _build_teams          { shift->_new_resource('Teams')                           }
sub _build_user           { shift->_new_resource('User', 'users')                   }
sub _build_users          { shift->_new_resource('Users')                           }
sub _build_webhooks       { shift->_new_resource('Webhooks', 'hooks')               }

################################################################################

1;
__END__

=head1 NAME

WebService::Mattermost::V4::API

=head1 DESCRIPTION

Container for API resources.

=head2 ATTRIBUTES

=over 4

=item C<brand>

See C<WebService::Mattermost::V4::API::Resource::Brand>.

=item C<channels>

See C<WebService::Mattermost::V4::API::Resource::Channels>.

=item C<channel>

See C<WebService::Mattermost::V4::API::Resource::Channel>.

=item C<channel_member>

See C<WebService::Mattermost::V4::API::Resource::Channel::Member>.

=item C<cluster>

See C<WebService::Mattermost::V4::API::Resource::Cluster>.

=item C<compliance>

See C<WebService::Mattermost::V4::API::Resource::Compliance>.

=item C<data_retention>

See C<WebService::Mattermost::V4::API::Resource::DataRetention>.

=item C<elasticsearch>

See C<WebService::Mattermost::V4::API::Resource::ElasticSearch>.

=item C<emoji>

See C<WebService::Mattermost::V4::API::Resource::Emoji>.

=item C<file>

See C<WebService::Mattermost::V4::API::Resource::File>.

=item C<files>

See C<WebService::Mattermost::V4::API::Resource::Files>.

=item C<jobs>

See C<WebService::Mattermost::V4::API::Resource::Jobs>.

=item C<ldap>

See C<WebService::Mattermost::V4::API::Resource::LDAP>.

=item C<oauth>

See C<WebService::Mattermost::V4::API::Resource::OAuth>.

=item C<plugin>

See C<WebService::Mattermost::V4::API::Resource::Plugin>.

=item C<plugins>

See C<WebService::Mattermost::V4::API::Resource::Plugins>.

=item C<post>

See C<WebService::Mattermost::V4::API::Resource::Post>.

=item C<posts>

See C<WebService::Mattermost::V4::API::Resource::Posts>.

=item C<reactions>

See C<WebService::Mattermost::V4::API::Resource::Reactions>.

=item C<roles>

See C<WebService::Mattermost::V4::API::Resource::Roles>.

=item C<saml>

See C<WebService::Mattermost::V4::API::Resource::SAML>.

=item C<schemes>

See C<WebService::Mattermost::V4::API::Resource::Schemes>.

=item C<system>

See C<WebService::Mattermost::V4::API::Resource::System>.

=item C<team>

See C<WebService::Mattermost::V4::API::Resource::Team>.

=item C<teams>

See C<WebService::Mattermost::V4::API::Resource::Teams>.

=item C<user>

See C<WebService::Mattermost::V4::API::Resource::User>.

=item C<users>

See C<WebService::Mattermost::V4::API::Resource::Users>.

=item C<webhooks>

See C<WebService::Mattermost::V4::API::Resource::Webhooks>.

=back

=head1 AUTHOR

Mike Jones L<email:mike@netsplit.org.uk>

