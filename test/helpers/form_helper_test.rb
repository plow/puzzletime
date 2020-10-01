#  Copyright (c) 2006-2017, Puzzle ITC GmbH. This file is part of
#  PuzzleTime and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/puzzletime.

require 'test_helper'

# Test FormHelper
class FormHelperTest < ActionView::TestCase
  include UtilityHelper
  include FormatHelper
  include I18nHelper
  include CrudTestHelper

  setup :reset_db, :setup_db, :create_test_data
  teardown :reset_db

  test 'plain form for existing entry' do
    e = crud_test_models('AAAAA')
    f = with_test_routing do
      capture do
        plain_form(e, html: { class: 'special' }) do |form|
          form.labeled_input_fields :name, :birthdate
        end
      end
    end

    assert_match /form .*?action="\/crud_test_models\/#{e.id}"
                       .*?method="post"/x, f
    assert_match /form .*?class="special\ form-horizontal"/x, f
    assert_match /input .*?type="hidden"
                        .*?name="_method"
                        .*?value="(patch|put)"/x, f
    assert_match /input .*?type="text"
                        .*?value="AAAAA"
                        .*?name="crud_test_model\[name\]"/x, f
  end

  test 'standard form' do
    e = crud_test_models('AAAAA')
    f = with_test_routing do
      capture do
        standard_form(e,
                      :name, :children, :birthdate, :human,
                      cancel_url: '/somewhere',
                      html: { class: 'special' })
      end
    end

    assert_match /form .*?action="\/crud_test_models\/#{e.id}"
                       .*?method="post"/x, f
    assert_match /form .*?class="special\ form-horizontal"/x, f
    assert_match /input .*?type="hidden"
                        .*?name="_method"
                        .*?value="(patch|put)"/x, f
    assert_match /input .*?type="text"
                        .*?value="AAAAA"
                        .*?name="crud_test_model\[name\]"/x, f
    assert_match /input .*?type="text"
                        .*?name="crud_test_model\[birthdate\]"/x, f
    assert_match /input .*?type="text"
                        .*?value="9"
                        .*?name="crud_test_model\[children\]"/x, f
    assert_match /input .*?type="checkbox"
                        .*?name="crud_test_model\[human\]"/x, f
    assert_match /button\ .*?type="submit".*\>
                  #{t('global.button.save')}
                  \<\/button\>/x, f
  end

  test 'standard form with errors' do
    e = crud_test_models('AAAAA')
    e.name = nil
    assert !e.valid?

    f = with_test_routing do
      capture do
        standard_form(e) do |form|
          form.labeled_input_fields(:name, :birthdate)
        end
      end
    end

    assert_match /form .*?action="\/crud_test_models\/#{e.id}"
                       .*?method="post"/x, f
    assert_match /input .*?type="hidden"
                        .*?name="_method"
                        .*?value="(patch|put)"/x, f
    assert_match /div[^>]* id='error_explanation'/, f
    assert_match /div\ class="field_with_errors"\>.*?
                  \<input .*?type="text"
                          .*?name="crud_test_model\[name\]"/x, f
    assert_match /input .*?value="01.01.1910"
                        .*?type="text"
                        .*?name="crud_test_model\[birthdate\]"/x, f
  end

  test 'crud form' do
    f = with_test_routing do
      capture { crud_form }
    end

    assert_match /form .*?action="\/crud_test_models\/#{entry.id}"/, f
    assert_match /input .*?name="crud_test_model\[name\]"
                        .*?type="text"/x, f
    assert_match /input .*?name="crud_test_model\[whatever\]"
                        .*?type="number"/x, f
    assert_match /input .*?type="text"
                        .*?name="crud_test_model\[children\]"/x, f
    assert_match /input .*?name="crud_test_model\[rating\]"
                        .*?type="text"/x, f
    assert_match /input .*?name="crud_test_model\[income\]"
                        .*?type="text"/x, f
    assert_match /input .*?type="text"
                        .*?name="crud_test_model\[birthdate\]"/x, f
    assert_match /input .*?type="time"
                        .*?name="crud_test_model\[gets_up_at\]"/x, f
    assert_match /input .*?type="datetime-local"
                        .*?name="crud_test_model\[last_seen\]"/x, f
    assert_match /input .*?type="checkbox"
                        .*?name="crud_test_model\[human\]"/x, f
    assert_match /select .*?name="crud_test_model\[companion_id\]"/, f
    assert_match /textarea .*?name="crud_test_model\[remarks\]"/, f
  end

  def entry
    @entry ||= CrudTestModel.first
  end

  def request
    m = mock
    f = mock
    f.stubs(:js?)
    m.stubs(:format).returns(f)
    m
  end
end
