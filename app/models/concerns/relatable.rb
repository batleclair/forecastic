module Relatable

  class Component
    attr_accessor :period, :metric, :label, :id, :code

    def initialize(code)
      @code = code
      @type = @code[/\#\{\d+\:\d+\}/] ? "metric" : "operator"
      @metric = Metric.find(@code[/\d+/].to_i) if @type == "metric"
      @label = @type == "metric" ? @metric.name : @code
      @id = @metric.id if @metric
      @period = @code[/\:\d+/][1..-1].to_i if @metric
    end

    def metric?
      @type == "metric"
    end
  end

  class Dependent
    attr_accessor :precedent, :metric, :period

    def initialize(params={})
      @metric = params.fetch(:metric)
      @precedent = params.fetch(:precedent)
      @period = set_period(params.fetch(:period))
    end

    def set_period(period)
      @metric.formula.body.scan()
    end
  end
end
