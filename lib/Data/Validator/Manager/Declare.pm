package Data::Validator::Manager::Declare;
use 5.008_001;
use strict;
use warnings;
use utf8;

our $VERSION = '0.01';

use Exporter ();
use Carp ();
use Data::Validator::Manager;
use namespace::clean ();

sub import {
    my $class  = shift;
    my $caller = caller;

    ## export sugers
    my %export_sugers = $class->export_sugers;
    foreach my $name (keys %export_sugers) {
        my $code = $export_sugers{$name};
        {
            no strict 'refs';
            *{"${caller}::${name}"} = $code;
        }
    }

    ## export functions
    my %export_functions = $class->export_functions;
    foreach my $name (keys %export_functions) {
        my $code = $export_functions{$name};
        {
            no strict 'refs';
            *{"${caller}::${name}"} = $code;
        }
    }

    ## setup Exporter
    {
        no strict 'refs';
        unshift @{"${caller}::ISA"}       => 'Exporter';
        unshift @{"${caller}::EXPORT_OK"} => keys %export_functions;
    }

    namespace::clean->import(
        -cleanee => $caller,
        -except  => [keys %export_functions],
    );
}

sub export_sugers {
    return (
        rule => sub ($$;@) {## no critic
            my $name = shift;
            my $rule = shift;

            my $manager = caller->manager;

            local $Carp::CarpLevel = $Carp::CarpLevel + 1;
            my $dv = $manager->add_rule($name => $rule);
            $dv->with(@_) if @_;

            return $dv;
        },
        with => sub (@) {## no critic
            return @_
        }
    );
}

sub export_functions {
    my $manager = Data::Validator::Manager->new;
    return (
        manager  => sub { $manager },
        get_rule => sub {
            local $Carp::CarpLevel = $Carp::CarpLevel + 1;
            $manager->get_rule(@_)
        },
        validate => sub {
            local $Carp::CarpLevel = $Carp::CarpLevel + 1;
            $manager->validate(@_)
        },
    );
}

__END__

=head1 NAME

Data::Validator::Manager::Declare - provides syntactic sugars for Data::Validator::Manager.

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

    use Proj::Validator qw/validate/;

    sub hoge {
        my($self, $args) = validate(hoge => @_);
    }

    1;

=head1 DESCRIPTION

This module provides syntactic sugars for L<Data::Validator::Manager>.
You can make the declaration of the validation rules by syntactic sugar.

=head1 INTERFACE

=head2 Syntactic Sugars

=head3 C<< rule(Str, HashRef, Array) >>

add validation rule.

  rule 'rule_name' => +{
      arg1 => 'Str',
      arg2 => 'Int'
  };

=head3 C<< with(Array) >>

add Role of Data::Validator.

This is syntactic sugar for arranging the appearance.
This does not actually do anything.

  rule 'rule_name' => +{
      arg1 => 'Str',
      arg2 => 'Int'
  } => with(qw/Method/);

=head2 Export functions

=head3 C<< get_rule(Str) >>

get validation rule. this function return object of Data::Validator.

  my $rule  = get_rule('no_throw_rule');
  my($args) = $rule->validate(@_);

  if ($rule->has_errors) {
      my $errors = $v->clear_errors;
      foreach my $e(@{$errors}) {
          print $e->{message}, "\n";
      }
  }

=head3 C<< validate(Str, Array) >>

execute validation.

  my $args = validate(rule_name => @_);

=head3 C<< manager() >>

get L<Data::Validator::Manager> instance.

  my $v = manager();

=head1 DEPENDENCIES

Perl 5.8.1 or later.

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=head1 SEE ALSO

L<Data::Validator>
L<Data::Validator::Manager>

=head1 AUTHOR

Kenta Sato E<lt>karupa@cpan.orgE<gt>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2012, Kenta Sato. All rights reserved.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
