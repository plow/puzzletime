#  Copyright (c) 2006-2017, Puzzle ITC GmbH. This file is part of
#  PuzzleTime and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/puzzletime.

# == Schema Information
#
# Table name: clients
#
#  id                  :integer          not null, primary key
#  work_item_id        :integer          not null
#  crm_key             :string
#  allow_local         :boolean          default(FALSE), not null
#  last_invoice_number :integer          default(0)
#  invoicing_key       :string
#  sector_id           :integer
#  e_bill_account_key  :string
#

class Client < ActiveRecord::Base
  include BelongingToWorkItem
  include Evaluatable

  belongs_to :sector, optional: true

  has_many :contacts, dependent: :destroy
  has_many :billing_addresses, dependent: :destroy

  has_descendants_through_work_item :orders
  has_descendants_through_work_item :accounting_posts

  validates_by_schema
  validates :work_item_id, uniqueness: true
  validates :crm_key, uniqueness: true, allow_blank: true
  validates :invoicing_key, uniqueness: true, allow_blank: true
  validates :e_bill_account_key, format: { with: /\A4110\d{13}\z/, allow_blank: true, message: :number }

  ##### interface methods for Evaluatable #####

  def self.worktimes
    Worktime.all
  end

  def self.plannings
    Planning.all
  end
end
