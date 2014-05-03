# materialized_views [![Code Climate](https://codeclimate.com/github/bluerogue251/materialized_views.png)](https://codeclimate.com/github/bluerogue251/materialized_views)

NOT ALL THE FUNCTIONALITY IN THIS README IS IMPLEMENTED YET.
Helper methods for creating auto-updating materialized views with ActiveRecord::Migration

## Installation

Add this line to your application's Gemfile:

    gem 'materialized_views'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install materialized_views

## Usage

Place any of the below methods within an `ActiveRecord::Migration` class.

### Create a materialized view:

Syntax:  `materialize(view_name_string, view_definition_string)`.

Example: `materialize 'order_summaries', 'select * from orders order by placed_on'`

This creates a regular view `order_summaries_unmaterialized`, and a its materialized version `order_summaries`.

### Create a function to refresh a row of the materialized view
The refreshed data comes from the underlying, unmaterialized version

Example: `create_refresh_row_function_for 'order_summaries'`

If your materialized view's primary key is not an integer or is not named 'id':
    `create_refresh_row_function_for 'order_summaries', pk: 'order_id', pk_type: 'text'`

### Add a tsvector column for faster full text searching:
Of course, you still need to configure `pg_search` or whatever you are using for full text search to actually use the tsvector column.
This method assumes you have a class method on your model called #searchable with the column names you want to search over.

Example:

    class OrderSummaries < ActiveRecord::Base
      def self.searchable
        %i(order_id customer payment_status shipping_status)
      end
    end

    Then in your migration:

    add_tsvector_to(OrderSummaries)

## Note on materialized views vs. tables

For compatibility with older versions of Postgres, these create 'tables', NOT 'materialized views'. Postgres 'materialized views' do not have enough functionality yet to make it worth using them over plain tables.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
