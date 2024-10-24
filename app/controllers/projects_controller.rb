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

  private

  def project_params
    params.require(:project).permit(:name, :description)
  end
end
