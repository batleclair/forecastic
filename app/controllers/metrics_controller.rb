class MetricsController < ApplicationController
  layout "modal", only: %i(new create edit update)

  def new
    @section = Section.find(params[:section_id])
    @sheet = @section.sheet
    @project = @sheet.project
    @metric = Metric.new
  end

  def create
    @section = Section.find(params[:section_id])
    @metric = Metric.new(metric_params)
    @metric.project = @section.project
    if @metric.save
      Row.create(section: @section, metric: @metric)
      redirect_to edit_metric_path(@metric)
    else
      render :new, status: 422
    end
  end

  def edit
    @metric = Metric.find(params[:id])
    if !params[:query].blank?
      @metrics = @metric.project.metrics.where.not(id: @metric.id).search_by_name(params[:query]).first(5)
    end
    # @metrics = @metrics.search_by_name(params[:query]) if params[:query] && !params[:query].blank?
  end

  def index

  end

  def update
    @metric = Metric.find(params[:id])
    @metric.assign_attributes(metric_params)
    if @metric.save
      redirect_to edit_metric_path(@metric)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def metric_params
    params.require(:metric).permit(:name, :fixed)
  end
end
