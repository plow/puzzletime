#  Copyright (c) 2006-2017, Puzzle ITC GmbH. This file is part of
#  PuzzleTime and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/puzzletime.

require 'test_helper'

# Test UtilityHelper
class UtilityHelperTest < ActionView::TestCase
  include CrudTestHelper

  test 'content_tag_nested escapes safe correctly' do
    html = content_tag_nested(:div, %w(a b)) { |e| content_tag(:span, e) }
    assert_equal '<div><span>a</span><span>b</span></div>', html
  end

  test 'content_tag_nested escapes unsafe correctly' do
    html = content_tag_nested(:div, %w(a b)) { |e| "<#{e}>" }
    assert_equal '<div>&lt;a&gt;&lt;b&gt;</div>', html
  end

  test 'content_tag_nested without block' do
    html = content_tag_nested(:div, %w(a b))
    assert_equal '<div>ab</div>', html
  end

  test 'safe_join without block' do
    html = safe_join(['<a>', '<b>'.html_safe])
    assert_equal '&lt;a&gt;<b>', html
  end

  test 'safe_join with block' do
    html = safe_join(%w(a b)) { |e| content_tag(:span, e) }
    assert_equal '<span>a</span><span>b</span>', html
  end

  test 'default attributes do not include id and password' do
    reset_db
    setup_db
    assert_equal [:name, :email, :whatever, :children, :companion_id, :rating,
                  :income, :birthdate, :gets_up_at, :last_seen, :human,
                  :remarks, :created_at, :updated_at],
                 default_crud_attrs
    reset_db
  end

  test 'column types' do
    reset_db
    setup_db
    create_test_data

    m = crud_test_models(:AAAAA)
    assert_equal :string, column_type(m, :name)
    assert_equal :integer, column_type(m, :children)
    assert_equal :integer, column_type(m, :companion_id)
    assert_nil column_type(m, :companion)
    assert_equal :float, column_type(m, :rating)
    assert_equal :decimal, column_type(m, :income)
    assert_equal :date, column_type(m, :birthdate)
    assert_equal :time, column_type(m, :gets_up_at)
    assert_equal :datetime, column_type(m, :last_seen)
    assert_equal :boolean, column_type(m, :human)
    assert_equal :text, column_type(m, :remarks)

    reset_db
  end
end
