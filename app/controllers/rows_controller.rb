class RowsController < ApplicationController
  layout "modal", only: %i(new create)
  before_action :set_row, only: %i(show destroy)
  before_action :set_section

  def new
    @row = Row.new(section: @section)
    @sheet = @section.sheet
    @project = @sheet.project
    @metrics = @project.metrics
    @metrics = @metrics.search_by_name(params[:query]) if params[:query] && !params[:query].blank?
    @metrics = @metrics.first(5)
  end

  def create
    @metric = Metric.find(params[:metric_id])
    @sheet = @section.sheet
    @project = @sheet.project
    @row = Row.new(section: @section, metric: @metric)
    if @row.save
      redirect_to project_sheet_path(@project, @sheet)
    else
      render :new, status: 422
    end
  end

  def show
    @sheet = @section.sheet
    @inactive_rows = @sheet.rows.where.not(id: @row.id)
    @inactive_sections = @sheet.sections.where.not(id: @section.id)
  end

  def destroy
    @row.destroy
    @sheet = @section.sheet
    respond_to do |format|
      format.turbo_stream { render turbo_stream: (turbo_stream.remove "row-#{@row.id}") }
      format.html { redirect_to project_sheet_path(@sheet.project, @sheet) }
    end
  end

  private

  def set_row
    @row = Row.find(params[:id])
  end

  def set_section
    @section = params[:section_id] ? Section.find(params[:section_id]) : @row.section
  end
end
