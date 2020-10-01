#  Copyright (c) 2006-2017, Puzzle ITC GmbH. This file is part of
#  PuzzleTime and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/puzzletime.

# A module to include into your functional tests for your crud controller
# subclasses. Simply implement the two methods #test_entry and
# #test_entry_attrs to test the basic crud functionality. Override the test
# methods if you changed the behaviour in your subclass controller.
module CrudControllerTestHelper
  extend ActiveSupport::Concern

  def test_index # :nodoc:
    get :index, params: test_params
    assert_response :success
    assert_template 'index'
    assert entries.present?
  end

  def test_index_json # :nodoc:
    get :index, params: test_params(format: 'json')
    assert_response :success
    assert entries.present?
    assert @response.body.starts_with?('[{'), @response.body
  end

  def test_index_search # :nodoc:
    field = @controller.search_columns.first
    val = field && test_entry[field].to_s
    return if val.blank? # does not support search or no value in this field

    get :index, params: test_params(q: val[0..((val.size + 1) / 2)])
    assert_response :success
    assert entries.present?
    assert entries.include?(test_entry)
  end

  def test_index_sort_asc # :nodoc:
    col = model_class.column_names.first
    get :index, params: test_params(sort: col, sort_dir: 'asc')
    assert_response :success
    assert entries.present?
    sorted = entries.sort_by(&(col.to_sym))
    assert_equal sorted, entries.to_a
  end

  def test_index_sort_desc # :nodoc:
    col = model_class.column_names.first
    get :index, params: test_params(sort: col, sort_dir: 'desc')
    assert_response :success
    assert entries.present?
    sorted = entries.to_a.sort_by(&(col.to_sym))
    assert_equal sorted.reverse, entries.to_a
  end

  def test_show # :nodoc:
    get :show, params: test_params(id: test_entry.id)
    assert_response :success
    assert_template 'show'
    assert_equal test_entry, entry
  end

  def test_show_json # :nodoc:
    get :show, params: test_params(id: test_entry.id, format: 'json')
    assert_response :success
    assert_equal test_entry, entry
    assert @response.body.starts_with?('{')
  end

  def test_show_with_non_existing_id_raises_record_not_found # :nodoc:
    assert_raise(ActiveRecord::RecordNotFound) do
      get :show, params: test_params(id: 9999)
    end
  end

  def test_new # :nodoc:
    get :new, params: test_params
    assert_response :success
    assert_template 'new'
    assert entry.new_record?
  end

  def test_create # :nodoc:
    assert_difference("#{model_class.name}.count") do
      post :create, params: test_params(model_identifier => new_entry_attrs)
      assert_equal [], entry.errors.full_messages
    end
    assert_redirected_to_index
    assert !entry.new_record?
    assert_attrs_equal(new_entry_attrs)
  end

  def test_create_json # :nodoc:
    assert_difference("#{model_class.name}.count") do
      post :create, params: test_params(model_identifier => new_entry_attrs,
                                        format: 'json')
    end
    assert_response :success
    assert @response.body.starts_with?('{"id":')
  end

  def test_edit # :nodoc:
    get :edit, params: test_params(id: test_entry.id)
    assert_response :success
    assert_template 'edit'
    assert_equal test_entry, entry
  end

  def test_update # :nodoc:
    assert_no_difference("#{model_class.name}.count") do
      put :update, params: test_params(id: test_entry.id,
                                       model_identifier => edit_entry_attrs)
      assert_equal [], entry.errors.full_messages
    end
    assert_attrs_equal(edit_entry_attrs)
    assert_redirected_to_index
  end

  def test_update_json # :nodoc:
    assert_no_difference("#{model_class.name}.count") do
      put :update, params: test_params(id: test_entry.id,
                                       model_identifier => edit_entry_attrs,
                                       format: 'json')
    end
    assert_response :success
    assert @response.body.starts_with?('{"id":')
  end

  def test_destroy # :nodoc:
    assert_difference("#{model_class.name}.count", -1) do
      delete :destroy, params: test_params(id: test_entry.id)
    end
    assert_redirected_to_index
  end

  def test_destroy_json # :nodoc:
    assert_difference("#{model_class.name}.count", -1) do
      delete :destroy, params: test_params(id: test_entry.id,
                                           format: 'json')
    end
    assert_response :success
    assert_equal '', @response.body.strip
  end

  def not_existing
    # run this method for disabled tests
  end

  private

  def assert_redirected_to_index # :nodoc:
    assert_redirected_to test_params(action: 'index',
                                     id: nil,
                                     returning: true)
  end

  def assert_redirected_to_show(entry) # :nodoc:
    assert_redirected_to test_params(action: 'show',
                                     id: entry.id)
  end

  def assert_attrs_equal(attrs) # :nodoc:
    assert_entry_attrs_equal(entry, attrs)
  end

  def assert_entry_attrs_equal(object, attrs)
    attrs.each do |key, value|
      if key.to_s.end_with?('_attributes')
        assert_entry_attrs_sub_entry(object, key, value)
      else
        actual = object.send(key)
        assert_equal value, actual,
                     "#{key} is expected to be <#{value.inspect}>, " \
                     "got <#{actual.inspect}>"
      end
    end
  end

  def assert_entry_attrs_sub_entry(object, key, value)
    sub_entry = object.send(key.to_s[0..(-'_attributes'.size - 1)])
    if sub_entry.is_a? ActiveRecord::Associations::CollectionProxy
      sub_entry.each_with_index do |array_sub_entry, index|
        assert_entry_attrs_equal(array_sub_entry, value[index.to_s])
      end
    else
      assert_entry_attrs_equal(sub_entry, value)
    end
  end

  # The model class under test.
  def model_class
    @controller.model_class
  end

  # The param key for model attributes.
  def model_identifier
    @controller.model_identifier
  end

  # The entry as set by the controller.
  def entry
    @controller.send(:entry)
  end

  # The entries as set by the controller.
  def entries
    @controller.send(:entries)
  end

  # Test object used in several tests.
  def test_entry
    fail 'Implement this method in your test class'
  end

  # Attribute hash used in several tests.
  def test_entry_attrs
    fail 'Implement this method in your test class'
  end

  # Attribute hash used in edit/update tests.
  def edit_entry_attrs
    test_entry_attrs
  end

  # Attribute hash used in new/create tests.
  def new_entry_attrs
    test_entry_attrs
  end

  # The params to pass to an action, including required nesting params.
  def test_params(params = {})
    nesting_params.merge(params)
  end

  # For nested controllers, collect hash with parent ids.
  def nesting_params
    params = {}
    Array(@controller.nesting).reverse.reduce(test_entry) do |parent, p|
      if p.is_a?(Class) && p < ActiveRecord::Base
        assoc = p.name.underscore
        params["#{assoc}_id"] = parent.send(:"#{assoc}_id")
        parent.send(assoc)
      else
        parent
      end
    end
    params
  end

  module ClassMethods
    def not_existing(*tests)
      tests.each do |method|
        alias_method method, :not_existing
      end
    end
  end
end
