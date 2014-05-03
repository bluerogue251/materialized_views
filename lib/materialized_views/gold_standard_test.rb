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
      @unm      = unmaterialized_class
      @mat_name = materialized_name
      @mat      = materialized_class
      @primary_key = @mat.primary_key
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

      def unmaterialized_class
        eval("class #{@unm_name.classify} < ActiveRecord::Base
                self.table_name = '#{@unm_name}'
              end")
        @unm_name.classify.constantize
      end

      def materialized_class
        classified = @mat_name.singularize.classify
        eval("class #{classified} < ActiveRecord::Base
                has_one :#{@unm_name}, foreign_key: '#{@primary_key}'
              end")
        classified.constantize
      end

      def total_count_check
        "Materialized count is #{@mat.count}.\n" +
        "Unmaterialized count is #{@unm.count}.\n" +
        "Difference is #{@mat.count - @unm.count}\n"
      end

      def row_comparison
        columns     = @mat.column_names - ['tsv']
        mat_columns = columns.map { |c|   "#{@mat_name}.#{c}" }.sort.join ', '
        unm_columns = columns.map { |c| "#{@unm_name}.#{c}" }.sort.join ', '
        count = @mat.joins(@unm_name.to_sym).where("concat(#{mat_columns}) != concat(#{unm_columns})").count
        "#{count} rows differ"
      end
  end
end
