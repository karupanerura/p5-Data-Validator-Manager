#!perl -w
use strict;
use warnings;
use utf8;

use Test::More;
use Test::Exception;

use t::Validator qw/get_rule validate manager/;

foreach my $name (qw/get_rule validate manager/) {
    ok __PACKAGE__->can($name), "$name export ok";
}

my $manager = manager();
isa_ok $manager, 'Data::Validator::Manager';

subtest 'get_rule' => sub {
    isa_ok get_rule('hoge'), 'Data::Validator';
    isa_ok get_rule('fuga'), 'Data::Validator';

    dies_ok {
        get_rule('foo')
    } 'undefined rule error';
    dies_ok {
        get_rule()
    } 'validete error';
};

subtest 'validate' => sub {
    subtest 'rule: hoge' => sub {
        my $code = sub {
            validate(hoge => @_);
        };

        dies_ok {
            $code->();
        } 'validate error';

        lives_and {
            is_deeply $code->(foo => 'sss'),               +{ foo => 'sss', bar => 'baz' }, 'returns ok';
            is_deeply $code->(foo => 'sss', bar => 'xxx'), +{ foo => 'sss', bar => 'xxx' }, 'returns ok';
        } 'validate success';
    };
    subtest 'rule: fuga' => sub {
        my $code = sub {
            validate(fuga => @_);
        };

        dies_ok {
            $code->(foo => 'sss');
        } 'validate error';

        lives_and {
            is_deeply [__PACKAGE__->$code(foo => 'sss')              ], [__PACKAGE__, +{ foo => 'sss', bar => 'baz' }], 'returns ok';
            is_deeply [__PACKAGE__->$code(foo => 'sss', bar => 'xxx')], [__PACKAGE__, +{ foo => 'sss', bar => 'xxx' }], 'returns ok';
        } 'validate success';
    };
};

subtest 'namespace::clean' => sub {
    dies_ok {
        t::Validator::rule(xxx => +{aaa => 'Str', bbb => 'Int'});
    } 'cannnot call suger "rule"';
    dies_ok {
        t::Validator::with(qw/Method/);
    } 'cannnot call suger "with"';
};

done_testing;
