# frozen_string_literal: true

Sidekiq.configure_server do |config|
  config.redis = Settings.redis.to_h
  config.logger.level = Rails.logger.level
end

Sidekiq.configure_client do |config|
  config.redis = Settings.redis.to_h
end

scheduled_jobs = {
  'schedule_uma' => {
    class: 'ScheduleUmaJob',
    cron:  '15 21 * * *',
    # args:  ['2022-01-05'],
  },
}
Sidekiq::Cron::Job.load_from_hash!(scheduled_jobs) unless Rails.env.test?
