#  Copyright (c) 2006-2017, Puzzle ITC GmbH. This file is part of
#  PuzzleTime and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/puzzletime.

class Order::Controlling
  attr_reader :order, :date

  def initialize(order, date = Time.zone.now)
    @order = order
    @date = date
  end

  def offered_total
    order.accounting_posts.sum(:offered_total)
  end

  def efforts_per_week
    {}.tap do |result|
      grouped_worktimes.each { |e| add_worktime(result, e) }
      grouped_plannings.each { |e| add_planning(result, e) }
      fill_week_gaps!(result)
    end
  end

  def efforts_per_week_cumulated
    efforts = efforts_per_week
    efforts.keys.sort.each_cons(2) do |previous_week, week|
      efforts[week] = sum_entries(efforts[previous_week], efforts[week])
    end
    efforts
  end

  private

  def grouped_worktimes
    load_worktimes
      .group('week, worktimes.billable')
      .order('week')
      .pluck('DATE_TRUNC(\'week\', work_date) week, worktimes.billable, SUM(hours * offered_rate)')
  end

  def grouped_plannings
    load_plannings
      .in_period(Period.with(date, nil))
      .group('week, offered_rate, definitive')
      .order('week')
      .pluck('DATE_TRUNC(\'week\', date) week, offered_rate, definitive, SUM(percent)')
  end

  def load_worktimes
    order
      .worktimes
      .joins('INNER JOIN accounting_posts ON accounting_posts.work_item_id = work_items.id')
  end

  def load_plannings
    Planning
      .joins(work_item: :accounting_post)
      .joins('LEFT JOIN orders ON orders.work_item_id = ANY (work_items.path_ids)')
      .where('orders.id = ?', order.id)
  end

  def add_worktime(result, entry)
    week, billable, hours = entry
    hours = 0.0 if hours.nil?
    add_value(result, week, billable ? :billable : :unbillable, hours)
  end

  def add_planning(result, entry)
    week, offered_rate, definitive, percent = entry
    must_hours = WorkingCondition.value_at(week, :must_hours_per_day).to_f
    effort = percent / 100.0 * must_hours * offered_rate.to_f
    add_value(result, week, definitive ? :planned_definitive : :planned_provisional, effort)
  end

  def add_value(result, week, key, value)
    unless result[week]
      result[week] = empty_entry
    end
    new_entry = empty_entry.tap { |e| e[key] = value ? value : 0.0 }
    result[week] = sum_entries(result[week], new_entry)
  end

  def sum_entries(a, b)
    result = empty_entry
    entry_keys.each do |key|
      result[key] = a[key] + b[key]
    end
    result
  end

  def empty_entry
    {}.tap { |e| entry_keys.each { |k| e[k] = 0.0 } }
  end

  def entry_keys
    [:billable, :unbillable, :planned_definitive, :planned_provisional]
  end

  def fill_week_gaps!(efforts)
    dates = efforts.keys.sort
    return if dates.size < 2

    for_each_week(dates.first, dates.last) do |week|
      unless dates.include?(week)
        efforts[week] = empty_entry
      end
    end
    efforts
  end

  def for_each_week(from, to)
    (from.beginning_of_week.to_date..to.beginning_of_week.to_date)
      .group_by { |d| "#{d.year}#{d.cweek}" }
      .each { |_, a| yield a.first.to_time(:utc) }
  end
end
