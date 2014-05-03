module MaterializedViews
  module GoldStandardTest

    def check_count
      mat_count   = count
      unmat_count = ActiveRecord::Base.connection.execute("select count(*) from #{to_s.tableize}_unmaterialized").first['count'].to_i
      puts "materialized count is #{mat_count}"
      puts "unmaterialized count is #{unmat_count}"
      raise CountError unless mat_count == unmat_count
    end

    def find_discrepancies
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

      raise DiscrepancyError unless count == 0
    end

    class CountError < StandardError; end
    class DiscrepancyError < StandardError; end
  end
end
