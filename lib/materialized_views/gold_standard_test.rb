module MaterializedViews

  class GoldStandardTest

    def initialize(model)
      @model       = model
      @mat_name    = model.table_name
      @unm_name    = @mat_name + '_unmaterialized'
      @columns     = model.column_names - ['tsv']
      @pk          = model.primary_key
    end

    def result
      @columns.each do |column|
        puts "#{row_comparison_query(column)} rows differ on #{column}"
      end
    end

    private

      def row_comparison_query(column)
        @model.joins("LEFT OUTER JOIN #{@unm_name} unm on #{@mat_name}.#{@pk} = unm.#{@pk}").where("COALSECE(#{@mat_name}.#{column}, '') != COALESCE(unm.#{column}, '')").count
      end

  end
end
