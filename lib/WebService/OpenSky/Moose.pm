package WebService::OpenSky::Moose;

# ABSTRACT: MooseX::Extended::Custom for WebService::OpenSky

use MooseX::Extended::Custom;
use PerlX::Maybe 'provided';
our $VERSION = '0.4';

# If $^P is true, we're running under the debugger.
#
# When running under the debugger, we disable __PACKAGE__->meta->make_immutable
# because the way the debugger works with B::Hooks::AtRuntime will cause
# the class to be made immutable before the we apply everything we need. This
# causes the code to die.
sub import ( $class, %args ) {
    MooseX::Extended::Custom->create(
        includes => 'method',
        provided $^P, excludes => 'immutable',
        %args    # you need this to allow customization of your customization
    );
}

__END__

=head1 DESCRIPTION

No user-serviceable parts inside.
