module Loopable

  class Cell
    attr_accessor :period, :metric, :project, :loop

    def initialize(params = {})
      @loop = 0
      @project = params.fetch(:project, nil)
      @period = params.fetch(:period, nil)
      @metric = params.fetch(:metric, nil)
    end

    def self.all
      ObjectSpace.each_object(self).to_a
    end

    def self.find_by(*args)
      all.find
    end

  end

end
