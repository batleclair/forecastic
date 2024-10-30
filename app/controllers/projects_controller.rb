class ProjectsController < ApplicationController
  layout "modal", only: [:new, :create, :edit, :update]
  before_action :set_project, only: %i(show edit update destroy)
  before_action :set_projects, only: %i(index show update)

  def index
    @projects = Project.all
  end

  def show
    @projects = Project.all
    @project = Project.find(params[:id])
  end

  def new
    @project = Project.new
  end

  def create
    @project = Project.new(project_params)
    if @project.save
      redirect_to project_sheet_path(@project, @project.sheets.first)
    else
      render :new, status: 422
    end
  end

  def edit
  end

  def update
    @project.assign_attributes(project_params)
    if @project.save
      # redirect_to project_path(@project)
      respond_to do |format|
        format.turbo_stream
      end
    else
      render :edit, status: 422
    end
  end

  def destroy
    @project.destroy
    redirect_to projects_path, status: 303
  end

  private

  def project_params
    params.require(:project).permit(:name, :description)
  end

  def set_project
    @project = Project.find(params[:id])
  end

  def set_projects
    @projects = Project.all
  end
end
