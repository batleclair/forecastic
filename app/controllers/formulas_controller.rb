class FormulasController < ApplicationController
  before_action :set_formula, only: %i(update destroy)

  def create
    @metric = Metric.find(params[:metric_id])
    @formula = Formula.create(metric: @metric)
    respond_to do |format|
      format.turbo_stream {render turbo_stream: (turbo_stream.replace "formula", partial: "formulas/builder", locals: {formula: @formula})}
    end
  end

  def update
    @formula.assign_attributes(formula_params)
    if @formula.save
      respond_to do |format|
        format.turbo_stream {render turbo_stream: (turbo_stream.replace "output", partial: "formulas/output", locals: {formula: @formula}) }
        format.html {redirect_to edit_metric_path(@formula.metric)}
      end
    else
      raise
    end
  end

  def destroy
    @formula.destroy
    redirect_to edit_metric_path(@formula.metric)
  end

  private

  def set_formula
    @formula = Formula.find(params[:id])
  end

  def formula_params
    params.require(:formula).permit(:body)
  end
end
