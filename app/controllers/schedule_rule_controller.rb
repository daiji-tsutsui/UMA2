# frozen_string_literal: true

# Schedule rule Setting Controller
class ScheduleRuleController < ApplicationController
  def index
    @target_rule = ScheduleRule.find_by(disable: 0)
    @rules = ScheduleRule.all
  end

  def edit
    @target_rule = ScheduleRule.find(params[:id])
    @rules = ScheduleRule.all
  end

  def update
    # Rails.logger.debug("Daiji log: #{params}")
    redirect_to schedule_rules_path and return
  end

  def new
    @rule_data = []
  end

  def create
    redirect_to schedule_rules_path and return
  end
end
