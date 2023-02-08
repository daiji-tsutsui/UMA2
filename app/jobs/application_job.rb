# frozen_string_literal: true

# Base class for jobs
class ApplicationJob < ActiveJob::Base
  def fetch_race_info(race_id)
    race = Race.find(race_id)
    [race.race_date.value, race.course.name, race.number]
  end
end
