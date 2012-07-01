package Data::Validator::Manager;
use 5.008_001;
use Mouse;
use MouseX::StrictConstructor;

our $VERSION = '0.01';

use Carp ();
use Data::Validator;

has rule => (
    is      => 'rw',
    isa     => 'HashRef[Data::Validator]',
    default => sub { +{} },
);

has add_rule_validator => (
    is      => 'ro',
    isa     => 'Data::Validator',
    default => sub {
        Data::Validator->new(
            name => 'Str',
            rule => 'HashRef'
        )->with(qw/StrictSequenced/);
    },
);

has get_rule_validator => (
    is      => 'ro',
    isa     => 'Data::Validator',
    default => sub {
        Data::Validator->new(
            name => 'Str',
        )->with(qw/StrictSequenced/);
    },
);

no Mouse;

sub add_rule {
    my $self = shift;
    my $args = $self->add_rule_validator->validate(@_);

    if (exists $self->rule->{ $args->{name} }) {
        Carp::croak "Duplicate rule: $args->{name}";
    }

    my $v = Data::Validator->new(%{ $args->{rule} });
    return $self->rule->{ $args->{name} } = $v;
}

sub get_rule {
    my $self = shift;
    my $args = $self->get_rule_validator->validate(@_);

    unless (exists $self->rule->{ $args->{name} }) {
        Carp::croak "Undefined rule: $args->{name}";
    }

    return $self->rule->{ $args->{name} };
}

sub clear_rule {
    my $self = shift;
    my $args = $self->get_rule_validator->validate(@_);

    unless (exists $self->rule->{ $args->{name} }) {
        Carp::croak "Undefined rule: $args->{name}";
    }

    return delete $self->rule->{ $args->{name} };
}

sub validate {
    my $self      = shift;
    my $rule_name = shift;

    local $Carp::CarpLevel = $Carp::CarpLevel + 1;
    return $self->get_rule($rule_name)->validate(@_);
}

__PACKAGE__->meta->make_immutable();
__END__

=head1 NAME

Data::Validator::Manager - instance manager for Data::Validator

=head1 VERSION

This document describes Data::Validator::Manager version 0.01.

=head1 SYNOPSIS

    use Data::Validator::Manager;

    my $v = Data::Validator::Manager->new;

    $v->add_rule(hoge => +{
        foo => 'Str',
        bar => +{ isa => 'Str', default => 'baz' },
    })->with(qw/Method/);

    sub hoge {
        my($self, $args) = $v->validate(hoge => @_);

        # logic...
    }

=head1 DESCRIPTION

This module is instance manager for Data::Validator.
This can be used to standardize as name the validation rules.

=head1 INTERFACE

=head2 Methods

=head3 C<< new() >>

create instance of this class.

  my $v = Data::Validator::Manager->new;

=head3 C<< add_rule(Str, HashRef) >>

add validation rule. this method return object of Data::Validator.

  $v->add_rule(rule_name => +{
      arg1 => 'Str',
      arg2 => 'Int'
  });

call with method, if you add Role of Data::Validator.

  $v->add_rule(rule_name => +{
      arg1 => 'Str',
      arg2 => 'Int'
  })->with(qw/StrictSequenced/);

=head3 C<< get_rule(Str) >>

get validation rule. this method return object of Data::Validator.

  my $rule  = $v->get_rule('no_throw_rule');
  my($args) = $rule->validate(@_);

  if ($rule->has_errors) {
      my $errors = $v->clear_errors;
      foreach my $e(@{$errors}) {
          print $e->{message}, "\n";
      }
  }

=head3 C<< clear_rule(Str) >>

clear validation rule. this method return object of Data::Validator.

  $v->clear_rule('temporary_rule');

=head3 C<< validate(Str, Array) >>

execute validation.

  my $args = $v->validate(rule_name => @_);

=head1 DEPENDENCIES

Perl 5.8.1 or later.

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=head1 SEE ALSO

L<Data::Validator>

=head1 AUTHOR

Kenta Sato E<lt>karupa@cpan.orgE<gt>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2012, Kenta Sato. All rights reserved.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
