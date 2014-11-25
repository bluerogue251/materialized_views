module MaterializedViews
  class TriggerDefinitions
    def initialize(tt, ot, mtotfk, trigger_types)
      @tt = tt
      @ot = ot
      @mtotfk = mtotfk
      @trigger_types = trigger_types
    end

    def each
      trigger_types.map do |type|
        name = "#{tt}_#{type[0]}_#{ot}"
        name += "_#{mtotfk}" if mtotfk
        "create trigger #{name}
         after #{type} on #{ot}
         for each row execute procedure #{name}();"
      end
    end

    private
    attr_reader :tt, :ot, :mtotfk, :trigger_types
  end
end
