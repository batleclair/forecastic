class EntriesController < ApplicationController
  before_action :set_constants

  def create
    @entry = Entry.new(entry_params)
    if @entry.save
      render turbo_stream: (turbo_stream.update "table", partial: "sheets/table")
    else
      raise
    end
  end

  def update
    @entry = Entry.find(params[:id])
    @entry.value = entry_params[:value]
    if @entry.save
      # render turbo_stream: (turbo_stream.update "cell", partial: "entries/cell", locals: {metric: @entry.metric, period: @entry.period})
      render turbo_stream: (turbo_stream.update "table", partial: "sheets/table")
    else
      raise
    end
  end

  private

  def entry_params
    params.require(:entry).permit(:value, :metric_id, :period_id)
  end

  def set_constants
    @sheet = Sheet.find(params[:sheet_id])
    @sections = @sheet.sections
    @project = @sheet.project
    @periods = @project.periods
  end
end
