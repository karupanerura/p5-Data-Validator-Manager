package t::Validator;
use strict;
use warnings;
use utf8;

use Data::Validator::Manager::Declare;

rule hoge => +{
    foo => 'Str',
    bar => +{ isa => 'Str', default => 'baz' }
};

rule fuga => +{
    foo => 'Str',
    bar => +{ isa => 'Str', default => 'baz' }
} => with(qw/Method/);

1;
