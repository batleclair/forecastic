class PeriodsController < ApplicationController
  before_action :set_project, only: %i(index)

  def index
    if params[:years]
      @periods = []
      @project.assign_attributes(project_params)
      n = params[:years].to_i * (12 / @project.p_factor)
      first_period = @project.first_end.prev_month(12 - @project.p_factor)
      for i in 0..(n-1) do
        @periods << Period.new(project: @project, date: first_period.next_month(i * @project.p_factor))
      end
    else
      @periods = @project.periods
    end
    @years = @periods.slice_after{|p| p.date.month == @project.first_end.month}.to_a
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def project_params
    params.require(:project).permit(:periodicity, :first_end)
  end
end
