# encoding: UTF-8

require 'test_helper'

class WorktimesCommitsControllerTest < ActionController::TestCase

  setup :login

  def test_edit_as_manager
    employee = employees(:various_pedro)
    employee.update!(committed_worktimes_at: Date.new(2015, 8, 31))
    get :edit, employee_id: employee.id
    assert_template '_form'

    selection = assigns(:commit_dates)
    assert_equal selection.size, 13
    assert_equal selection.first.first, Time.zone.today.end_of_month
  end

  def test_edit_as_regular_user
    login_as(:various_pedro)
    employee = employees(:various_pedro)
    employee.update!(committed_worktimes_at: Date.new(2015, 8, 31))
    get :edit, employee_id: employee.id
    assert_template '_form'

    selection = assigns(:commit_dates)
    assert_equal selection.size, 2
    assert_equal selection.first.first, Time.zone.today.end_of_month - 1.month
  end

  def test_edit_as_regular_user_is_not_allowed_for_somebody_else
    login_as(:various_pedro)
    assert_raise(CanCan::AccessDenied) do
      get :edit, employee_id: employees(:mark).id
    end
  end

  def test_update
    employee = employees(:various_pedro)
    employee.update!(committed_worktimes_at: Date.new(2015, 8, 31))
    eom = Time.zone.now.end_of_month.to_date
    patch :update,
          employee_id: employee.id,
          employee: { committed_worktimes_at: eom }
    assert_equal eom, employee.reload.committed_worktimes_at
  end

  def test_update_is_not_allowed_with_arbitrary_dates
    employee = employees(:various_pedro)
    employee.update!(committed_worktimes_at: Date.new(2015, 8, 31))
    eom = Time.zone.now.end_of_month
    patch :update,
          employee_id: employee.id,
          employee: { committed_worktimes_at: Date.new(2015, 10, 15) }
    assert_equal Date.new(2015, 8, 31), employee.reload.committed_worktimes_at
    assert_template '_form'
    assert_match /nicht erlaubt/, assigns(:employee).errors.full_messages.join
  end

end