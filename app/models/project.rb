# project.rb

class Project < ApplicationRecord
  include Sizeable
  validates :name, presence: true
  has_many :tasks, dependent: :destroy

  def self.velocity_length_in_days
    21
  end

  def incomplete_tasks
    tasks.reject(&:complete?)
  end

  def done?
    incomplete_tasks.empty?
  end

  def size
    tasks.sum(&:size)
  end

  def remaining_size
    incomplete_tasks.sum(&:size)
  end

  def completed_velocity
    tasks.sum(&:points_toward_velocity)
  end

  def current_rate
    completed_velocity * 1.0 / Project.velocity_length_in_days
  end

  def projected_days_remaining
    remaining_size / current_rate
  end

  def on_schedule?
    return false if projected_days_remaining.nan?
    (Time.zone.today + projected_days_remaining) <= due_date
  end

  def self.find_recently_started(time_span)
    old_time = Date.today - time_span
    all(conditions: [ "start_date > ?", old_time.to_s(:db) ])
  end
end
