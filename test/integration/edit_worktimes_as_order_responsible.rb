#  Copyright (c) 2006-2017, Puzzle ITC GmbH. This file is part of
#  PuzzleTime and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/puzzletime.

require 'test_helper'

class EditWorktimesAsOrderResponsibleTest < ActionDispatch::IntegrationTest
  setup :login

  test 'can change own committed worktimes on own order' do
    find('a.add-other').click
    assert_selector('.btn-primary')

    click_button 'Speichern'
    assert_no_selector('.btn-primary')

    visit('/ordertimes/10/edit')
    assert_selector('form[action="/ordertimes/10"]')

    click_button 'Speichern'
    assert_no_selector('.alert.alert-danger')
    assert_selector('.alert.alert-success')
  end

  def login
    login_as(:lucien)
  end
end
