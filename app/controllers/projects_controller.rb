class ProjectsController < ApplicationController
  layout "modal", only: [:new, :create]

  def index
    @projects = Project.all
  end

  def show
    @project = Project.find(params[:id])
  end

  def new
    @project = Project.new
  end

  def create
    @project = Project.new(project_params)
    if @project.save
      redirect_to project_path(@project)
    else
      render :new, status: 422
    end
  end

  def input
    @sheet = Sheet.find(params[:sheet_id])
    @project = @sheet.project
    @periods = @project.periods
    @metric = Metric.find(params[:metric_id])
    period = Period.find(params[:period_id])

    @project.assign_value(@metric, period, params[:value])
    @project.assign_dependents(@metric, period)
    @project.save

    @sections = @sheet.sections
    render turbo_stream: (turbo_stream.update "table", partial: "sheets/table")
  end

  private

  def project_params
    params.require(:project).permit(:name, :description)
  end
end
