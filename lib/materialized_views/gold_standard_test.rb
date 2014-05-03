module MaterializedViews

  def self.gold_standard_test(views)
    result = ''
    views.each { |view| result << GoldStandardTest.new(view).result }
    result
  end

  def self.list
    all_views = ActiveRecord::Base.connection.query('SELECT viewname
                                                     FROM pg_views
                                                     WHERE schemaname = ANY (current_schemas(false))',
                                                     'SCHEMA').map { |row| row[0] }
    all_views.keep_if { |view| view.end_with? '_unmaterialized' }
  end

  class GoldStandardTest

    def initialize(unmaterialized_name)
      @unm_name = unmaterialized_name
      @mat_name = materialized_name
    end

    def result
      result = "\n\n\n{@mat}\n"
      result += total_count_check
      result += row_comparison
    end

    private

      def materialized_name
        @unm[/(.*)(_unmaterialized\z)/]
        $1
      end

      def total_count_check
        "Materialized count is #{@mat.count}.\n" +
        "Unmaterialized count is #{@unm.count}.\n" +
        "Difference is #{@mat.count - @unm.count}\n"
      end

      def row_comparison
        count = ActiveRecord::Base.connection.query(row_comparison_query).first[0]
        "#{count} rows differ"
      end

      def row_comparison_query
        columns     = @mat.column_names - ['tsv']
        mat_columns = columns.map { |c|   "#{@mat_name}.#{c}" }.sort.join ', '
        unm_columns = columns.map { |c| "#{@unm_name}.#{c}" }.sort.join ', '
        "select count(*) from #{@mat_name}
         LEFT OUTER JOIN #{@unm_name}
           ON #{@mat_name}.#{@primary_key} = #{@unm_name}.#{@primary_key}
         WHERE concat(#{mat_columns}) != concat(#{unm_columns})"
      end
  end
end
