class SheetsController < ApplicationController
  before_action :set_sheet, only: %i(show edit update destroy sort)
  before_action :set_project

  def show
    @periods = @project.periods
    @sections = @sheet.sections
    @metrics = Metric.joins(:rows).where(rows: { section_id: @sections.pluck(:id) }).distinct
    # refresh_worksheet
    # raise
  end

  def create
    @sheet = Sheet.create(project: @project)
    redirect_to project_sheet_path(@project, @sheet)
  end

  def edit
    @project = @sheet.project
  end

  def update
    @sheet.update(sheet_params)
    redirect_to project_sheet_path(@project, @sheet)
  end

  def destroy
    @sheet.destroy
    redirect_to project_sheet_path(@project, @project.sheets.first)
  end

  def sort
    @sheet.insert_at(params[:position].to_i)
  end

  private

  def set_project
    @project = @sheet ? @sheet.project : Project.find(params[:project_id])
    @sheets = @project.sheets
  end

  def set_sheet
    @sheet = Sheet.find(params[:id])
  end

  def sheet_params
    params.require(:sheet).permit(:name)
  end

  def refresh_worksheet
    @output = {}
    @metrics.includes(:formula).each do |metric|
      @output[:"#{metric.id}"] = {}
      @periods.includes(:entries).each do |period|
        @output[:"#{metric.id}"][:"#{period.id}"] = {
          entry: period.entries.find_by(metric: metric),
          calc: metric.formula.process(period)
        }
      end
    end
    @output
  end
end
