# frozen_string_literal: true

class TestJob < ApplicationJob
  queue_as :default

  def perform(str)
    puts "Hello, world! #{str}"
    'OK'
  end
end
