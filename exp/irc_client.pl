package Nazuna::IRCClient;
use MooseX::POE;

sub START {
    my ($self) = @_;
    $self->yield('increment');
}

event increment => sub {
    my ($self) = @_;
    print "Event occured!";
    $self->yield('increment');
};
no MooseX::POE;

package main;

Nazuna::IRCClient->new;
POE::Kernel->run;
