#!perl -w
use strict;
use warnings;
use utf8;

use Test::More;
use Test::Exception;

use Data::Validator::Manager;

my $manager = Data::Validator::Manager->new;
isa_ok $manager, 'Data::Validator::Manager';

subtest 'add_rule' => sub {
    isa_ok $manager->add_rule(hoge => +{
        foo => 'Str',
        bar => +{ isa => 'Str', default => 'baz' }
    }), 'Data::Validator';
    isa_ok $manager->add_rule(fuga => +{
        foo => 'Str',
        bar => +{ isa => 'Str', default => 'baz' }
    })->with(qw/Method/), 'Data::Validator';

    dies_ok {
        $manager->add_rule(fuga => +{
            foo => 'Str',
            bar => +{ isa => 'Str', default => 'baz' }
        })
    } 'duplicate rule error';
    dies_ok {
        $manager->add_rule()
    } 'validete error';
};

subtest 'get_rule' => sub {
    isa_ok $manager->get_rule('hoge'), 'Data::Validator';
    isa_ok $manager->get_rule('fuga'), 'Data::Validator';

    dies_ok {
        $manager->get_rule('foo')
    } 'undefined rule error';
    dies_ok {
        $manager->get_rule()
    } 'validete error';
};

subtest 'clear_rule' => sub {
    $manager->clear_rule('fuga');
    dies_ok {
        $manager->get_rule('fuga')
    } 'clear success';
    lives_and {
        isa_ok $manager->get_rule('hoge'), 'Data::Validator';
    } 'no clear other';

    dies_ok {
        $manager->clear_rule('foo')
    } 'undefined rule error';
    dies_ok {
        $manager->clear_rule()
    } 'validate error';
};

subtest 'validate' => sub {
    my $code = sub {
        $manager->validate(hoge => @_);
    };

    dies_ok {
        $code->();
    } 'validate error';

    lives_and {
        is_deeply $code->(foo => 'sss'),               +{ foo => 'sss', bar => 'baz' }, 'returns ok';
        is_deeply $code->(foo => 'sss', bar => 'xxx'), +{ foo => 'sss', bar => 'xxx' }, 'returns ok';
    } 'validate success';
};

done_testing;
