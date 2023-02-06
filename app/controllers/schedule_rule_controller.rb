# frozen_string_literal: true

# Schedule rule Setting Controller
class ScheduleRuleController < ApplicationController
  def index
    @using_rule = ScheduleRule.find_by(disable: 0)
    @rules = ScheduleRule.all
  end

  def edit
    @rules = ScheduleRule.all
  end

  # def update
  # end

  # def new
  # end

  # def create
  # end
end
