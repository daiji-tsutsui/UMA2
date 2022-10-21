# frozen_string_literal: true

class InsertInitialCoureses < ActiveRecord::Migration[7.0]
  def change
    courses = %w[札幌 函館 福島 中山 東京 新潟 中京 京都 阪神 小倉]
    courses.each do |course|
      Course.create(name: course)
    end
  end
end
