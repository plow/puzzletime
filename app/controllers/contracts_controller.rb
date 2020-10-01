#  Copyright (c) 2006-2017, Puzzle ITC GmbH. This file is part of
#  PuzzleTime and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/puzzletime.

class ContractsController < CrudController
  self.nesting = Order

  self.permitted_attrs = :number, :start_date, :end_date, :payment_period, :reference, :notes, :sla

  skip_authorize_resource
  before_action :authorize_class

  def update
    super(location: edit_order_contract_path(order_id: parent))
  end

  private

  def order
    @order ||= Order.find(params[:order_id])
  end

  def entry
    @contract ||= order.try(:contract) || build_entry
  end

  def build_entry
    Contract.new(order: parent)
  end

  def parent_scope
    parent.send(:contract)
  end

  def authorize_class
    authorize!(:"#{action_name}_contract", order)
  end
end
