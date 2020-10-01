#  Copyright (c) 2006-2017, Puzzle ITC GmbH. This file is part of
#  PuzzleTime and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/puzzletime.

class EmployeeStatistics
  attr_reader :employee

  def initialize(employee)
    @employee = employee
  end

  #########  vacation information ############

  # Returns the unused days of vacation remaining until the end of the current year.
  def current_remaining_vacations
    remaining_vacations(Date.new(Time.zone.today.year, 12, 31))
  end

  # Returns the unused days of vacation remaining until the given date.
  def remaining_vacations(date)
    period = employment_period_to(date)
    return 0 if period.nil?

    @employee.initial_vacation_days +
      total_vacations(period) +
      overtime_vacation_days(period) -
      used_vacations(period)
  end

  # Returns the overall amount of granted vacation days for the given period.
  def total_vacations(period)
    employments_during(period).sum(&:vacations).to_f
  end

  # Returns the used vacation days for the given period
  def used_vacations(period)
    return 0 if period.nil?

    WorkingCondition.sum_with(:must_hours_per_day, period) do |p, hours|
      @employee.worktimes.in_period(p).
        joins(:absence).
        where(absences: { vacation: true }).
        sum(:hours).to_f / hours
    end
  end

  ###########  absence information  ###################

  def absences(period, payed = nil)
    worktimes = @employee.worktimes.joins(:absence).in_period(period)

    worktimes = worktimes.where(absences: { payed: payed }) if payed.in? [true, false]

    worktimes.sum(:hours).to_f
  end

  ###########  overtime information  ###################

  # Returns the overall overtime hours until the given date.
  # Default is yesterday.
  def current_overtime(date = Time.zone.today - 1)
    overtime(employment_period_to(date)) - overtime_vacation_hours(date)
  end

  # Returns the overtime hours worked in the given period.
  def overtime(period)
    payed_worktime(period) - musttime(period)
  end

  # Returns the hours this employee has to work in the given period.
  def musttime(period)
    employments_during(period).sum(&:musttime)
  end

  # Returns an Array of all employements during the given period,
  # an empty Array if no employments exist.
  def employments_during(period)
    return [] if period.nil?

    employments = @employee.employments.during(period).reorder('start_date').to_a
    Employment.normalize_boundaries(employments, period)
  end

  ######### worktime information ####################

  def pending_worktime(period)
    musttime(period) -
      payed_worktime(period) -
      compensated_overtime(period)
  end

  private

  # Returns the hours this employee worked plus the payed absences for the given period.
  def payed_worktime(period)
    @employee.worktimes.
      joins('LEFT JOIN absences ON absences.id = absence_id').
      in_period(period).
      where('((work_item_id IS NOT NULL AND absence_id IS NULL) OR absences.payed)').
      sum(:hours).
      to_f
  end

  # Returns the hours this employee compensated overtime.
  def compensated_overtime(period)
    @employee.worktimes
      .joins('LEFT JOIN absences ON absences.id = absence_id')
      .in_period(period)
      .where('(absences.compensation) AND NOT (absences.payed)')
      .sum(:hours)
      .to_f
  end

  # Return the overtime days that were transformed into vacations up to the given date.
  def overtime_vacation_days(period)
    WorkingCondition.sum_with(:must_hours_per_day, period) do |p, hours|
      @employee.overtime_vacations.
        where('transfer_date BETWEEN ? AND ?', p.start_date, p.end_date).
        sum(:hours).
        to_f / hours
    end
  end

  # Return the overtime hours that were transformed into vacations up to the given date.
  def overtime_vacation_hours(date = nil)
    @employee.overtime_vacations.
      where(date ? ['transfer_date <= ?', date] : nil).
      sum(:hours).
      to_f
  end

  ######### employment helpers ######################

  # Returns the Period from the first employement date until the given period.
  # Returns nil if no employments exist until this date.
  def employment_period_to(date)
    first_employment = @employee.employments.reorder('start_date ASC').first
    return nil if first_employment.nil? || first_employment.start_date > date

    Period.new(first_employment.start_date, date)
  end
end
