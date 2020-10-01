#  Copyright (c) 2006-2017, Puzzle ITC GmbH. This file is part of
#  PuzzleTime and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/puzzletime.

require 'test_helper'

class InvoicesControllerTest < ActionController::TestCase
  include CrudControllerTestHelper

  setup { Invoicing.instance = nil }
  setup :login

  def test_show_with_non_existing_id_raises_record_not_found
    # we redirect to allow order changes with dropdown
    get :show, params: { id: 42, order_id: test_entry.order_id }
    assert_redirected_to order_invoices_path(test_entry.order_id)
  end

  test 'GET new with params from order_services view filter assigns correct attributes' do
    test_entry.destroy!
    login_as :mark
    get :new,
        params: {
          order_id: test_entry.order_id,
          employee_id: employees(:pascal).id,
          work_item_id: work_items(:webauftritt).id,
          start_date: start_date = '01.12.2006',
          end_date: end_date = '31.12.2006'
        }
    assert_response :success
    assert_template 'invoices/_form'
    assert_equal([employees(:pascal)], entry.employees)
    assert_equal([work_items(:webauftritt)], entry.work_items)
    assert_equal(Date.parse(start_date), entry.period_from)
    assert_equal(Date.parse(end_date), entry.period_to)
    assert_nil entry.grouping
  end

  test 'GET new without params sets defaults' do
    test_entry.update!(grouping: 'manual')
    worktimes(:wt_pz_webauftritt).update!(billable: true)
    get :new, params: { order_id: test_entry.order_id }
    assert_response :success
    assert_equal(Time.zone.today, entry.billing_date)
    assert_equal(Time.zone.today + contracts(:webauftritt).payment_period.days, entry.due_date)
    assert_equal(employees(:mark, :lucien, :pascal).sort, entry.employees.sort)
    assert_equal([work_items(:webauftritt)], entry.work_items)
    assert(test_entry.order.default_billing_address_id, entry.billing_address_id)
    assert_equal('manual', entry.grouping)
  end

  test 'GET preview_total' do
    params = {
      order_id: test_entry.order_id,
      employee_id: employees(:mark).id,
      work_item_id: work_items(:webauftritt).id,
      start_date: '01.12.2006',
      end_date: '31.12.2006'
    }

    get :preview_total, xhr: true, params: params.merge(format: :js)

    preview_value = response.body[/html\('(.+) #{Settings.defaults.currency}'\)/, 1].to_f
    assert_equal(entry.calculated_total_amount, preview_value)
  end

  test 'GET billing_addresses' do
    get :billing_addresses,
        xhr: true,
        params: {
          order_id: test_entry.order_id,
          invoice: { billing_client_id: clients(:swisstopo).id }
        }

    assert_equal clients(:swisstopo), assigns(:billing_client)
    assert_equal billing_addresses(:swisstopo, :swisstopo_2), assigns(:billing_addresses)
  end

  test 'PUT sync as management' do
    login_as :mark
    params = {
      order_id: test_entry.order_id,
      id: test_entry.id
    }
    put :sync, params: params
    assert_response :redirect
  end

  test 'PUT sync as order responsible for responsible order' do
    login_as :long_time_john
    params = {
      order_id: test_entry.order_id,
      id: test_entry.id
    }
    put :sync, params: params
    assert_response :redirect
  end

  test 'PUT sync as order responsible for not responsible order' do
    login_as :lucien
    params = {
      order_id: test_entry.order_id,
      id: test_entry.id
    }
    assert_raise CanCan::AccessDenied do
      put :sync, params: params
    end
  end

  test 'PUT sync as non order responsible' do
    login_as :pascal
    params = {
      order_id: test_entry.order_id,
      id: test_entry.id
    }
    assert_raise CanCan::AccessDenied do
      put :sync, params: params
    end
  end

  test 'DELETE as management' do
    login_as :mark
    params = {
      order_id: test_entry.order_id,
      id: test_entry.id
    }
    delete :destroy, params: params
    assert_response :redirect
  end

  test 'DELETE as order responsible for responsible order' do
    login_as :long_time_john
    params = {
      order_id: test_entry.order_id,
      id: test_entry.id
    }
    delete :destroy, params: params
    assert_response :redirect
  end

  test 'DELETE as order responsible for not responsible order' do
    login_as :lucien
    params = {
      order_id: test_entry.order_id,
      id: test_entry.id
    }
    assert_raise CanCan::AccessDenied do
      delete :destroy, params: params
    end
  end

  test 'DELETE as non order responsible' do
    login_as :pascal
    params = {
      order_id: test_entry.order_id,
      id: test_entry.id
    }
    assert_raise CanCan::AccessDenied do
      delete :destroy, params: params
    end
  end

  test 'DELETE draft destroys record' do
    login_as :mark
    params = {
      order_id: test_entry.order_id,
      id: test_entry.id
    }
    delete :destroy, params: params

    assert_raise ActiveRecord::RecordNotFound do
      Invoice.find(test_entry.id)
    end
  end

  test 'DELETE sent marks record as cancelled' do
    login_as :mark
    test_entry.status = 'sent'
    test_entry.save!
    params = {
      order_id: test_entry.order_id,
      id: test_entry.id
    }
    delete :destroy, params: params

    assert Invoice.find(test_entry.id).status == 'cancelled'
  end

  %w(cancelled unknown).each do |status|
    test "DELETE #{status} marks record as deleted" do
      login_as :mark

      test_entry.status = status
      test_entry.save!
      params = {
        order_id: test_entry.order_id,
        id: test_entry.id
      }
      delete :destroy, params: params

      assert Invoice.find(test_entry.id).status == 'deleted'
    end
  end

  %w(deleted paid partially_paid).each do |status|
    test "DELETE #{status} is not permitted" do
      login_as :mark

      test_entry.status = status
      test_entry.save!
      params = {
        order_id: test_entry.order_id,
        id: test_entry.id
      }
      assert_raise CanCan::AccessDenied do
        delete :destroy, params: params
      end
    end
  end

  private

  # Test object used in several tests.
  def test_entry
    invoices(:webauftritt_may)
  end

  def test_entry_attrs
    {
      order_id: orders(:webauftritt).id,
      employee_ids: Array(employees(:pascal).id),
      work_item_ids: Array(work_items(:webauftritt).id),
      period_from: Date.parse('01.12.2006'),
      period_to: Date.parse('15.12.2006')
    }
  end

  def edit_entry_attrs
    {
      employee_ids: Array(employees(:lucien).id),
      period_from: Date.parse('01.12.2007'),
      period_to: Date.parse('15.12.2007')
    }
  end
end
