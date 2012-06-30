package Data::Validator::Manager::Declare;
use 5.008_001;
use strict;
use warnings;
use utf8;

use parent qw/Exporter/;

our $VERSION = '0.01';

use Carp ();
use Data::Validator::Manager;

# export functions
our @EXPORT = qw/rule with/;

sub rule ($$;@) {## no critic
    my $name = shift;
    my $rule = shift;

    my $manager = caller->manager;

    local $Carp::CarpLevel = $Carp::CarpLevel + 1;
    my $dv = $manager->add_rule($name => $rule);
    $dv->with(@_) if @_;

    return $dv;
}

sub with (@) {## no critic
    return @_
}

sub import {
    my $class  = shift;
    my $caller = caller;

    ## export methods
    my %export_methods = $class->export_methods;
    foreach my $name (keys %export_methods) {
        my $code = $export_methods{$name};
        {
            no strict 'refs';
            *{"${caller}::${name}"} = $code;
        }
    }

    $class->export_to_level(1, @_);
}

sub export_methods {
    my $manager = Data::Validator::Manager->new;
    return (
        import   => sub {
            my $class  = shift;
            my $caller = caller;

            while (my $export = shift) {
                unless ($class->can($export)) {
                    Carp::croak qq{Can't export "${export}" via package "${class}"};
                }

                my $code = sub {
                    local $Carp::CarpLevel = $Carp::CarpLevel + 1;
                    $class->$export(@_);
                };

                no strict 'refs';
                *{"${caller}::${export}"} = $code;
            }
        },
        manager  => sub { $manager },
        get_rule => sub {
            local $Carp::CarpLevel = $Carp::CarpLevel + 1;
            shift->manager->get_rule(@_)
        },
        validate => sub {
            local $Carp::CarpLevel = $Carp::CarpLevel + 1;
            shift->manager->validate(@_)
        },
    );
}

__END__

=head1 NAME

Data::Validator::Manager::Declare - Perl extention to do something

=head1 VERSION

This document describes Data::Validator::Manager::Declare version 0.01.

=head1 SYNOPSIS

    package Proj::Validator;
    use strict;
    use warnings;
    use utf8;

    use Data::Validator::Manager::Declare;

    rule hoge => +{
        foo => 'Str',
        bar => +{ isa => 'Str', default => 'baz' },
    } => with(qw/Method/);

    1;

    package Proj::FugaClass;
    use strict;
    use warnings;
    use utf8;

    use Proj::Validator;

    sub hoge {
        my($self, $args) = Proj::Validator->instance->validate(hoge => @_);
    }

    1;

=head1 DESCRIPTION

# TODO

=head1 INTERFACE

=head2 Functions

=head3 C<< hello() >>

# TODO

=head1 DEPENDENCIES

Perl 5.8.1 or later.

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=head1 SEE ALSO

L<perl>

=head1 AUTHOR

<<YOUR NAME HERE>> E<lt><<YOUR EMAIL ADDRESS HERE>>E<gt>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2012, <<YOUR NAME HERE>>. All rights reserved.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
