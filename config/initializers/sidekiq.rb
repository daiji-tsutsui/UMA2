# frozen_string_literal: true

Sidekiq.configure_server do |config|
  config.redis = Settings.redis.to_h
  config.logger.level = Rails.logger.level
end

Sidekiq.configure_client do |config|
  config.redis = Settings.redis.to_h
end

scheduled_jobs = {
  'fetch_course_names' => {
    class: 'FetchCourseNamesJob',
    cron:  'H 2 * * *',
    # args:  ['cron_test'],
  },
}
Sidekiq::Cron::Job.load_from_hash!(scheduled_jobs) unless Rails.env.test?
