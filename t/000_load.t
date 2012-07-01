#!perl -w
use strict;
use Test::More tests => 1;

BEGIN {
    use_ok 'Data::Validator::Manager';
}

diag "Testing Data::Validator::Manager/$Data::Validator::Manager::VERSION";
eval { require Mouse };
diag "Mouse/$Mouse::VERSION";
