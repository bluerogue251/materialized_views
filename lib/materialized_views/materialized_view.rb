module MaterializedViews
  class MaterializedView
    attr_accessor :name, :definition, :primary_key, :primary_key_data_type

    def initialize
      @primary_key = 'id'
      @primary_key_data_type = 'integer'
    end

    def create_unmaterialized_version
      "create view #{name}_unmaterialized as #{definition}"
    end

    def create_materialized_version
      "create table #{name} as select * from #{name}_unmaterialized"
    end

    def create_refresh_row_function
      "create or replace function refresh_#{name}_row(row_id #{primary_key_data_type})
       returns void
       language 'plpgsql' as $$
       begin
         delete from #{name} where #{name}.#{primary_key} = row_id;
         insert into #{name} (select * from #{name}_unmaterialized unm where unm.#{primary_key} = row_id);
       end $$;"
    end
  end
end
