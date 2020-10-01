#  Copyright (c) 2006-2017, Puzzle ITC GmbH. This file is part of
#  PuzzleTime and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/puzzletime.

require 'test_helper'

class BillingAddressesControllerTest < ActionController::TestCase
  include CrudControllerTestHelper

  setup :login

  not_existing :test_show,
               :test_show_json,
               :test_show_with_non_existing_id_raises_record_not_found

  private

  # Test object used in several tests.
  def test_entry
    billing_addresses(:puzzle)
  end

  # Attribute hash used in several tests.
  def test_entry_attrs
    { supplement: 'foo',
      street: 'Hauptstrasse 1',
      zip_code: '1234',
      town: 'Hauptstadt',
      country: 'DE' }
  end
end
