class SectionsController < ApplicationController
  before_action :set_section, only: %i(show edit update destroy sort)
  before_action :set_constants, only: %i(show edit update)

  def create
    @sheet = Sheet.find(params[:sheet_id])
    @section = Section.create(sheet: @sheet)
    respond_to do |format|
      format.turbo_stream {render turbo_stream: (turbo_stream.append "sections", partial: "sections/default", locals: {section: @section})}
      format.html
    end
  end

  def show
    @sections = @sheet.sections
    @inactive_sections = @sections.where.not(id: @section.id)
  end

  def edit
  end

  def update
    @section.update(section_params)
    redirect_to project_sheet_path(@sheet.project, @sheet)
  end

  def destroy
    @sheet = @section.sheet
    @section.destroy
    respond_to do |format|
      format.turbo_stream { render turbo_stream: (turbo_stream.remove "section-#{@section.id}") }
      format.html { redirect_to project_sheet_path(@sheet.project, @sheet) }
    end
  end

  def sort
    @section.insert_at(params[:position].to_i)
  end

  private

  def set_section
    @section = Section.find(params[:id])
  end

  def section_params
    params.require(:section).permit(:name)
  end

  def set_constants
    @sheet = @section.sheet
    @project = @sheet.project
    @periods = @project.periods
  end

end
