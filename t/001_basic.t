#!perl -w
use strict;
use Test::More;

use Data::Validator::Manager;

# test Data::Validator::Manager here
my $object = Data::Validator::Manager->new;
isa_ok $object, 'Data::Validator::Manager';

done_testing;
