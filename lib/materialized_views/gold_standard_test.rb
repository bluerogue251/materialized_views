module MaterializedViews

  class GoldStandardTest

    def initialize(model)
      @model                = model
      @materialized_table   = model.table
      @unmaterialized_table = @materialized_table + '_unmaterialized'
      @columns              = (model.column_names - ['tsv']).join(',')
    end

    def result
      puts @model.find_by_sql("SELECT #{@columns} FROM #{@materialized_table} EXCEPT SELECT #{@columns} FROM #{@unmaterialized_table}
                               UNION
                               SELECT #{@columns} FROM #{@unmaterialized_table} EXCEPT SELECT #{@columns} FROM #{@materialized_table}").to_yaml
    end
  end
end
