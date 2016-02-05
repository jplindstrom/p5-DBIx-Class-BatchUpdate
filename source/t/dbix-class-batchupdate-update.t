use strict;
use warnings;
use Test::More;
use Test::Differences;
use Test::MockObject;

use Storable qw/ thaw /;

use DBIx::Class::BatchUpdate::Update;



my $empty_batch = DBIx::Class::BatchUpdate::Update->new({ rows => [] });



subtest batch_key => sub {
    my $key_value = { id => 3, price => 42, author_id => undef };
    my $md5 = qr/[^,]+/;
    eq_or_diff(
        thaw( $empty_batch->batch_key($key_value) ),
        $key_value,
        "Correct batch_key (as far as we can tell)",
    );
};



###JPL: die if dirty PK?



subtest "Empty rows" => sub {
    is_deeply(
        $empty_batch->batches,
        [],
        "Empty rows, no batches",
    );
};

my $update_call_count = 0;
my $search_args = [];
my $resultset = Test::MockObject->new
    ->mock(
        search => sub {
            my $self = shift;
            my ($args) = @_;
            push(@$search_args, $args);
            Test::MockObject->new
                ->mock(update => sub { $update_call_count++ }),
            },
    );

sub get_row {
    my ($row_id, $key_value, $pk_columns) = @_;
    $pk_columns //= [ "pkid" ], # Non standard PK

        return Test::MockObject->new
        ->set_always(id => $row_id)
        ->mock(get_dirty_columns => sub { return %$key_value })
        ->mock(
            result_source => sub {
                Test::MockObject->new
                    ->set_always(resultset => $resultset)
                    ->set_always(primary_columns => @$pk_columns)
                },
        )
        ;
}

subtest "Rows with different values" => sub {
    ## Setup

    my $rows = [
        get_row(1, { is_out_of_print => 1 }),
        get_row(2, { is_out_of_print => 1 }),
        get_row(3, { is_out_of_print => 1, price => 42 }),
    ];

    my $batch = DBIx::Class::BatchUpdate::Update->new({ rows => $rows });

    ## Run
    $batch->update();


    ## Test
    is($update_call_count, 2, "update was called once for each combo");
    eq_or_diff(
        $search_args,
        [
            { pkid => { -in => [ 1, 2 ] } }, # is_out_of_print
            { pkid => { -in => [ 3 ]    } }, # is_out_of_print, price
        ],
    );
};



###JPL: multiple PKs




done_testing;
