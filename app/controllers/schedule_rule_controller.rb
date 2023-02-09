# frozen_string_literal: true

# Schedule rule Setting Controller
class ScheduleRuleController < ApplicationController
  before_action :prepare_target_rule, only: %i[edit update]
  before_action :prepare_form_data,   only: %i[update create]

  ERROR_MESSAGE_NO_VALID_SCHEDULE_RULES = 'There are no valid schedule rules...'
  ERROR_MESSAGE_NO_SUCH_SCHEDULE_RULE   = 'There is no such a schedule rule...'
  ERROR_MESSAGE_NO_DATA_GIVEN           = 'Please enter clauses for a schedule rule.'
  ERROR_MESSAGE_SOMETHING_WENT_WRONG    = 'Sorry. Something went wrong...'

  def index
    @rules = ScheduleRule.all.order(id: :ASC)
    @target_rule = ScheduleRule.find_by(disable: 0)
    return unless @target_rule.nil?

    flash[:danger] = ERROR_MESSAGE_NO_VALID_SCHEDULE_RULES
    redirect_to root_path
  end

  def edit
    @rules = ScheduleRule.all.order(id: :ASC)
    return unless @target_rule.nil?

    flash[:danger] = ERROR_MESSAGE_NO_SUCH_SCHEDULE_RULE
    redirect_to schedule_rules_path
  end

  def update
    redirect_back(fallback_location: schedule_rules_path) and return if @form_data.empty?

    ScheduleRule.transaction do
      ScheduleRule.update_all(disable: 1)
      @target_rule.update!(disable: 0, data_json: @form_data.to_json)
    end
    redirect_to schedule_rules_path
  rescue ActiveRecord::ActiveRecordError
    flash[:danger] = ERROR_MESSAGE_SOMETHING_WENT_WRONG
    redirect_back(fallback_location: schedule_rules_path)
  end

  def new
    @rule_data = []
  end

  def create
    redirect_to new_schedule_path and return if @form_data.empty?

    ScheduleRule.transaction do
      ScheduleRule.update_all(disable: 1)
      ScheduleRule.create!(disable: 0, data_json: @form_data.to_json)
    end
    redirect_to schedule_rules_path
  end

  private

  def prepare_target_rule
    @target_rule = ScheduleRule.find(params[:id])
  end

  def prepare_form_data
    @form_data = format_form_params
    flash[:danger] = ERROR_MESSAGE_NO_DATA_GIVEN if @form_data.empty?
  end

  def form_params
    params.permit(duration: [], interval: [])
  end

  def format_form_params
    durations = convert_to_integer(form_params[:duration])
    intervals = convert_to_integer(form_params[:interval])
    return [] if durations.size != intervals.size || durations.empty?

    durations.map.with_index do |duration, i|
      {
        duration: duration,
        interval: intervals[i],
      }
    end
  end

  def convert_to_integer(array)
    array.map(&:to_i).select(&:positive?)
  end
end
