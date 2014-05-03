# materialized_views [![Code Climate](https://codeclimate.com/github/bluerogue251/materialized_views.png)](https://codeclimate.com/github/bluerogue251/materialized_views)

NOT ALL THE FUNCTIONALITY IN THIS README IS IMPLEMENTED YET.

Extends `ActiveRecord::Migration` with methods for creating auto-updating materialized views in Postgres.

Can perform a gold standard test to check if a materialized view is up-to-date with its unmaterialized version.

## Installation

Add `gem 'materialized_views'` to your application's Gemfile and then execute `$ bundle`

Or install it yourself as `$ gem install materialized_views`

## Usage

Place any of the below methods within an `ActiveRecord::Migration` class.

### Create a materialized view:
Syntax:

    materialize(materialized_view_name, view_definition)

Example:

    materialize 'order_summaries', 'select * from orders order by placed_on'

This creates a regular view `order_summaries_unmaterialized`, and a table `order_summaries` to hold its materialized version.

### Create a function to refresh a row of the materialized view
The refreshed data comes from the underlying, unmaterialized version

Syntax:

    create_refresh_row_function_for(materialized_view_name, options={})

Example:

    create_refresh_row_function_for 'order_summaries'

If your materialized view's primary key is not an integer or is not named 'id':

    create_refresh_row_function_for 'order_summaries', pk: 'order_code', pk_type: 'text'

### Create 1 to 1 refresh triggers

Syntax:

    create_1_to_1_refresh_triggers_for(
                                        materialized_view_name,
                                        origin_table_name,
                                        foreign_key_name
                                      )

Example:

    create_1_to_1_refresh_triggers_for 'order_summaries', 'orders', 'id'

### Create 1 to n refresh triggers
Syntax:

    create_1_to_n_refresh_triggers_for(
                                        materialized_view_name,
                                        origin_table_name,
                                        join_table_name,
                                        join_table_materialized_view_foreign_key,
                                        join_table_origin_table_foreign_key
                                      )

Example:

    create_1_to_n_refresh_triggers_for 'order_summaries', 'customers', 'orders', 'code', 'customer_id'

### Test if a materialized view is up-to-date

This one is a good candidate for a Rake task.  It does not go inside a migration.

Syntax:

    views = MaterializedViews.list

    MaterializedViews.gold_standard_test(views)

Example:

    # in lib/tasks/materialized_view_test.rake
    namespace :materialized do
      desc 'Tests that materialized views are up to date'
      task test: :environment do
        view_names = MaterializedViews.list
        result = MaterializedViews.gold_standard_test(view_names)
        puts result # or you could email the result to yourself, or put it into a file for later viewing
      end
    end

    # Then at the console in your project root directory:
    $ rake materialized:test

### Add a tsvector column for faster full text searching:

Syntax:

    add_tsvector_to(materialized_view_name, searchable_column_array)

Example:

    add_tsvector_to 'order_summaries', %w(order_code customer payment_status shipping_status)

And then configure `pg_search` or whatever you are using to use the resulting tsvector column.


## Note on materialized views vs. tables

For compatibility with older versions of Postgres, these create 'tables', NOT 'materialized views'. Postgres 'materialized views' do not have enough functionality yet to make it worth using them over plain tables.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
