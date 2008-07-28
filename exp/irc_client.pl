package Nazuna::IRCClient;
use MooseX::POE;

use POE qw(Component::IRC);
use POE::Sugar::Args;

has irc => ( 
    is  => 'rw',
    isa => 'POE::Component::IRC',
);

has config => (
    is  => 'ro',
    isa => 'HashRef',
);

sub START {
    my ($self) = @_;

    $self->irc(POE::Component::IRC->spawn(
        nick     => $self->config->{name},
        username => $self->config->{username},
        ircname  => $self->config->{ircname},
        server   => $self->config->{server},
        password => $self->config->{password},
    ));

    $self->yield( register => 'all' );
    $self->yield( connect  => { } );

    return;
}

sub irc_001 { # FIXME なぜか呼ばれない
    my ($self) = @_;

    print "Connected to ", $self->irc->server_name, "\n";

    for my $channel ( @{ $self->config->{channels} } ) {
        $self->irc->yield(join => $channel);
    }

    return;
}


event _default => sub {
    my ($self) = @_;
    my $poe = sweet_args;
    my ($event, $args) = $poe->args;

    my @output = ( "$event: " );

    for my $arg (@$args) {
        if ( ref $arg eq 'ARRAY' ) {
            push( @output, '[' . join(' ,', @$arg ) . ']' );
        }
        else {
            push ( @output, "'$arg'" );
        }
    }
    print join ' ', @output, "\n";

    return 0;
};


no MooseX::POE;


package main;

use YAML;
use Perl6::Say;
use Findbin;

my $config = YAML::LoadFile(File::Spec->catfile($FindBin::Bin, 'config.yaml'));

Nazuna::IRCClient->new( config => $config );
POE::Kernel->run;



