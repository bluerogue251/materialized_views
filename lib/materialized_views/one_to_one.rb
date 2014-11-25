module MaterializedViews
  class OneToOne
    def initialize(target:, origin:, foreign_key:)
      @target      = target
      @origin      = origin
      @foreign_key = foreign_key
    end

    def all_definitions
      each_function_definition + each_trigger_definition
    end

    def each_function_definition
      [insert_function_sql, update_function_sql, delete_function_sql]
    end

    def each_trigger_definition
      TriggerDefinitions.new(target, origin, foreign_key, ['insert', 'update', 'delete']).each
    end

    def update_function_sql
      "create or replace function #{target}_u_#{origin}()
       returns trigger
       language 'plpgsql' as $$
       begin
         if old.#{foreign_key} = new.#{foreign_key} then
           perform refresh_#{target}_row(new.#{foreign_key});
         else
           perform refresh_#{target}_row(old.#{foreign_key});
           perform refresh_#{target}_row(new.#{foreign_key});
        end if;
       return null;
       end $$;"
    end

    def insert_function_sql
      "create or replace function #{target}_i_#{origin}()
       returns trigger
       language 'plpgsql' as $$
       begin
         perform refresh_#{target}_row(new.#{foreign_key});
       return null;
       end $$;"
    end

    def delete_function_sql
      "create or replace function #{target}_d_#{origin}()
       returns trigger
       language 'plpgsql' as $$
       begin
         perform refresh_#{target}_row(old.#{foreign_key});
       return null;
       end $$;"
    end

    private
    attr_reader :target, :origin, :foreign_key
  end
end

