module MaterializedViews
  def add_tsvector_to(model)
    execute "alter table #{model.table_name} add column tsv tsvector"

    execute "create trigger tsvectorupdate
             before insert or update
             on #{model.table_name} for each row execute procedure
             tsvector_update_trigger(tsv, 'pg_catalog.simple', #{model.searchable.join ', '});"
  end

  def materialize(view_name, view_definition)
    execute "create view #{view_name}_unmaterialized as #{view_definition}"
    execute "create table #{view_name} as select * from #{view_name}_unmaterialized"
  end

  # tt = target_table
  # ot = origin_table
  # mt = middle table (table through which a 1 to n relationship is realized)
  # mtfk = middle table foreign key
  # fk = foreign_key

  def create_refresh_row_function_for(tt, pk, type = 'integer')
    execute "create or replace function refresh_#{tt}_row(row_id #{type})
             returns void
             language 'plpgsql' as $$
             begin
               delete from #{tt} where #{tt}.#{pk} = row_id;
               insert into #{tt} (select * from #{tt}_unmaterialized unm where unm.#{pk} = row_id);
               update #{tt} set #{pk} = #{pk} where #{pk} = row_id;
             end $$;"
  end

  # Origin table primary key
  def create_1_to_1_refresh_triggers_for(tt, ot, fk)
    execute "create or replace function #{tt}_u_#{ot}()
             returns trigger
             language 'plpgsql' as $$
             begin
               if old.#{fk} = new.#{fk} then
                 perform refresh_#{tt}_row(new.#{fk});
               else
                 perform refresh_#{tt}_row(old.#{fk});
                 perform refresh_#{tt}_row(new.#{fk});
              end if;
             return null;
             end $$;"

    execute "create or replace function #{tt}_i_#{ot}()
             returns trigger
             language 'plpgsql' as $$
             begin
               perform refresh_#{tt}_row(new.#{fk});
             return null;
             end $$;"

    execute "create or replace function #{tt}_d_#{ot}()
             returns trigger
             language 'plpgsql' as $$
             begin
               perform refresh_#{tt}_row(old.#{fk});
             return null;
             end $$;"

    create_triggers_on(tt, ot, nil, ['insert', 'update', 'delete'])
  end

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
    trigger_types.each do |type|
      name = "#{tt}_#{type[0]}_#{ot}"
      name += "_#{mtotfk}" if mt
      execute "create trigger #{name}
               after #{type} on #{ot}
               for each row execute procedure #{name}();"
    end
  end
end

ActiveRecord::Migration.send :include, MaterializedViews
