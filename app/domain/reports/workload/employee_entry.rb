#  Copyright (c) 2006-2017, Puzzle ITC GmbH. This file is part of
#  PuzzleTime and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/puzzletime.

module Reports
  class Workload
    class EmployeeEntry < BaseEntry
      attr_reader :employee

      delegate :to_s, to: :employee

      def initialize(employee, period, employments, worktimes)
        @employee = employee
        super(period, employments, worktimes)
      end

      def order_entries
        @order_entries ||= build_entries
      end

      private

      def build_entries
        ordertimes.group_by(&:order_work_item).map do |work_item, ordertimes|
          ordertime_hours = ordertimes.sum(&:hours)
          billable_hours = ordertimes.select(&:billable).sum(&:hours) || 0
          billability = billable_hours > 0 ? billable_hours / ordertime_hours : 0
          Reports::Workload::OrdertimeEntry.new(work_item, ordertime_hours, billability)
        end
      end
    end
  end
end
