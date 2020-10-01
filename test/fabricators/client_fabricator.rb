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

Fabricator(:client) do
  work_item
end
