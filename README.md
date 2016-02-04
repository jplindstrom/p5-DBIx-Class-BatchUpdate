p5-DBIx-Class-BatchUpdate
============================

## NAME

DBIx::Class::BatchUpdate - Update batches of DBIC rows with as few
queries as possible

## SYNOPSIS

    # In your result class, e.g. MySchema::ResultSet::Book
    __PACKAGE__->load_components("BatchUpdate");


    # In your code, update loads of row objects and keep track of them
    $book_row1->is_out_of_print(1);
    $book_row2->is_out_of_print(1);
    $book_row3->is_out_of_print(1);
    $book_row3->price(42);
    my $book_rows = [ $book_row1, $book_row2, $book_row3 ];

    # Batch update all rows in as few UPDATE statements as possible
    $schema->resultset("Book")->batch_update($book_rows);

    # SQL queries
    # 1 UPDATE for all the rows with is_out_of_print: 1
    # 1 UPDATE for all the rows with is_out_of_print: 1, price: 42


    # Alternatively, create your own BatchUpdate::Update object:
    use DBIx::Class::BatchUpdate::Update;

    DBIx::Class::BatchUpdate::Update->new({
        rows => $rows,
    })->update();

## DESCRIPTION

This module is for when you have loads of DBIC rows to update as part of
some large scale processing, and you want to avoid making individual
calls to $row->update for each of them. If the number of dirty rows is
large, the many round-trips to the database will be quite time
consuming.

So instead of calling $row->update you collect all the dirty row objects
(of the same Result class) for later and then let
DBIx::Class::BatchUpdate update the database with as few queries as
possible.

This means that if the same columns have been set to the same value in
all the rows, this will be done in a single query. The more different
combinations of columns and values there are in rows, the more queries
are required.


## Details

See [DBIx::Class::BatchUpdate](https://metacpan.org/pod/DBIx::Class::BatchUpdate) on metacpan.org

