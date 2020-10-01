#  Copyright (c) 2006-2017, Puzzle ITC GmbH. This file is part of
#  PuzzleTime and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/puzzletime.

class ReportType
  include Comparable

  attr_reader :key, :name, :accuracy

  START_STOP = false

  def self.[](key)
    ALL_INSTANCES.each { |type| return type if type.key == key }
  end

  def to_s
    key
  end

  def <=>(other)
    return unless other.is_a?(ReportType)

    accuracy <=> other.accuracy
  end

  def validate_worktime(worktime)
    worktime.errors.add(:hours, 'Stunden müssen positiv sein') if worktime.hours.to_f <= 0
  end

  def copy_times(source, target)
    target.hours = source.hours
  end

  def start_stop?
    self.class::START_STOP
  end

  def date_string(date)
    I18n.l(date, format: :long)
  end

  module Accessors
    def report_type
      type = self['report_type']
      type.is_a?(String) ? ReportType[type] : type
    end

    def report_type=(type)
      type = type.key if type.is_a? ReportType
      self['report_type'] = type
    end
  end

  protected

  def initialize(key, name, accuracy)
    @key = key
    @name = name
    @accuracy = accuracy
  end

  def rounded_hours(worktime)
    hour = worktime.hours || 0.0
    minutes = ((hour - hour.floor) * 60).round.to_s.rjust(2, '0')
    hours = ActiveSupport::NumberHelper.number_to_delimited(hour.floor, delimiter: "'")
    "#{hours}:#{minutes}".html_safe
  end
end

class StartStopType < ReportType
  INSTANCE = new 'start_stop_day', 'Von/Bis Zeit', 10
  START_STOP = true

  def time_string(worktime)
    if worktime.from_start_time.is_a?(Time) &&
       worktime.to_end_time.is_a?(Time)
      I18n.l(worktime.from_start_time, format: :time) + ' - ' +
        I18n.l(worktime.to_end_time, format: :time) +
        ' (' + rounded_hours(worktime) + ' h)'
    end
  end

  def copy_times(source, target)
    super source, target
    target.from_start_time = source.from_start_time
    target.to_end_time = source.to_end_time
  end

  def validate_worktime(worktime)
    unless worktime.from_start_time.is_a?(Time)
      worktime.errors.add(:from_start_time, 'Die Anfangszeit ist ungültig')
    end
    unless worktime.to_end_time.is_a?(Time)
      worktime.errors.add(:to_end_time, 'Die Endzeit ist ungültig')
    end
    if worktime.from_start_time.is_a?(Time) && worktime.to_end_time.is_a?(Time) &&
       worktime.to_end_time <= worktime.from_start_time
      worktime.errors.add(:to_end_time, 'Die Endzeit muss nach der Startzeit sein')
    end
    if worktime.from_start_time&.to_date != worktime.to_end_time&.to_date
      worktime.errors.add(:to_end_time, 'Die Endzeit muss zwischen 00:00-23:59 liegen')
    end
  end
end

class AutoStartType < StartStopType
  INSTANCE = new 'auto_start', 'Von/Bis offen', 12

  def time_string(worktime)
    if worktime.from_start_time.is_a?(Time)
      'Start um ' + I18n.l(worktime.from_start_time, format: :time)
    end
  end

  def validate_worktime(worktime)
    # set defaults
    worktime.work_date = Time.zone.today
    worktime.hours = 0
    worktime.to_end_time = nil
    # validate
    unless worktime.from_start_time.is_a?(Time)
      worktime.errors.add(:from_start_time, 'Die Anfangszeit ist ungültig')
    end
    if worktime.employee
      existing = worktime.employee.send("running_#{worktime.class.name[0..-5].downcase}".to_sym)
      if existing && existing != worktime
        worktime.errors.add(:employee_id, "Es wurde bereits eine offene #{worktime.class.model_name.human} erfasst")
      end
    end
  end
end

class HoursDayType < ReportType
  INSTANCE = new 'absolute_day', 'Stunden/Tag', 6

  def time_string(worktime)
    rounded_hours(worktime) + ' h'
  end
end

class HoursWeekType < ReportType
  INSTANCE = new 'week', 'Stunden/Woche', 4

  def time_string(worktime)
    rounded_hours(worktime) + ' h in dieser Woche'
  end

  def date_string(date)
    I18n.l(date, format: 'W %V, %Y')
  end
end

class HoursMonthType < ReportType
  INSTANCE = new 'month', 'Stunden/Monat', 2

  def time_string(worktime)
    rounded_hours(worktime) + ' h in diesem Monat'
  end

  def date_string(date)
    I18n.l(date, format: '%m.%Y')
  end
end

class ReportType
  INSTANCES = [StartStopType::INSTANCE,
               HoursDayType::INSTANCE,
               HoursWeekType::INSTANCE,
               HoursMonthType::INSTANCE].freeze
  ALL_INSTANCES = INSTANCES + [AutoStartType::INSTANCE]
end
