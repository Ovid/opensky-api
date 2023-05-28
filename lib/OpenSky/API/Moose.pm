# ABSTRACT: MooseX::Extended::Custom for OpenSky::API

package OpenSky::API::Moose;

our $VERSION = '0.001';
use MooseX::Extended::Custom;

# If $^P is true, we're running under the debugger.
#
# When running under the debugger, we disable __PACKAGE__->meta->make_immutable
# because the way the debugger works with B::Hooks::AtRuntime will cause
# the class to be made immutable before the we apply everything we need. This
# causes the code to die.
sub import {
    my ( $class, %args ) = @_;

    # we exclude strictconstructor because, otherwise, the delayed param trick
    # for OpenSky::API::Core will fail.
    my @excludes = 'StrictConstructor';
    if ($^P) {
        state $warned;
        unless ($warned) {
            $warned++;
            say STDERR "Running under the debugger. Excluding make_immutable\n";
        }
    }
    else {
        push @excludes => 'immutable';
    }
    push @excludes => 'immutable' unless $^P;
    MooseX::Extended::Custom->create(
        includes => [ 'method', 'try' ],
        excludes => \@excludes,
        %args    # you need this to allow customization of your customization
    );
}

__END__

=head1 DESCRIPTION

No user-serviceable parts inside.
