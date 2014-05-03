module MaterializedViews

  def gold_standard_test(views)
    result = ''
    views.map { |view| result << GoldStandardTest.new(view).result }
    result
  end

  def list
    all_views = ActiveRecord::Base.connection.query('SELECT viewname
                                                     FROM pg_views
                                                     WHERE schemaname = ANY (current_schemas(false))',
                                                     'SCHEMA').map { |row| row[0] }
    all_views.keep_if { |view| view.end_with? '_unmaterialized' }
  end

  class GoldStandardTest

    def initialize(view_name)
    end

    def result
      result = "view_name\n\n"
    end

    private

      def check_total_count(view)
        mat_count   = count
        unmat_count = ActiveRecord::Base.connection.execute("select count(*) from #{to_s.tableize}_unmaterialized").first['count'].to_i
        puts "materialized count is #{mat_count}"
        puts "unmaterialized count is #{unmat_count}"
      end

      def check_row_contents(view)
        pk = primary_key
        columns = column_names - ['tsv']
        table = to_s.tableize
        mat_columns = columns.map { |c| "#{table}.#{c}" }.sort.join ', '
        unm_columns = columns.map { |c|      "unm.#{c}" }.sort.join ', '

        count = self.joins {
          "left outer join #{table}_unmaterialized unm
           on #{table}.#{pk} = unm.#{pk}"
        }.where {
          "concat(#{mat_columns}) != concat(#{unm_columns})"
        }.count
      end
  end
end
