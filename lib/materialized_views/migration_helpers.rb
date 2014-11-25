module MaterializedViews
  def add_tsvector_to(model)
    execute "alter table #{model.table_name} add column tsv tsvector"

    execute "create trigger tsvectorupdate
             before insert or update
             on #{model.table_name} for each row execute procedure
             tsvector_update_trigger(tsv, 'pg_catalog.simple', #{model.searchable.join ', '});"
  end

  # tt = target_table
  # ot = origin_table
  # mt = middle table (table through which a 1 to n relationship is realized)
  # mtfk = middle table foreign key
  # fk = foreign_key

  # mttfk Middle table foreign key pointing to the target table
  # mtofk Middle table foreign key pointing to the origin table
  # otpk  Origin table primary key
  def create_1_to_n_refresh_triggers_for(tt, ot, mt, mtttfk, mtotfk, otpk)

    execute "create or replace function #{tt}_u_#{ot}_#{mtotfk}()
             returns trigger
             language 'plpgsql' as $$
             begin
               if old.#{otpk} = new.#{otpk} then
                 perform refresh_#{tt}_row(#{mtttfk}) from #{mt} where #{mtotfk} = new.#{otpk};
               else
                 perform refresh_#{tt}_row(#{mtttfk}) from #{mt} where #{mtotfk} = old.#{otpk};
                 perform refresh_#{tt}_row(#{mtttfk}) from #{mt} where #{mtotfk} = new.#{otpk};
               end if;
               return null;
             end
             $$;"

    create_triggers_on(tt, ot, mtotfk, ['update'])
  end

  def create_triggers_on(tt, ot, mtotfk, trigger_types)
    TriggerDefinitions.new(tt, ot, mtotfk, trigger_types).each do |sql|
      execute sql
    end
  end
end

ActiveRecord::Migration.send :include, MaterializedViews
