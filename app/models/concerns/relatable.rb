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
    attr_accessor :calc, :input, :dependents

    def initialize(params={})
      @input = params.dig(:input)
      @calc = params.dig(:calc)
      @dependents = params.dig(:dependents) || {}
    end

  end
end
