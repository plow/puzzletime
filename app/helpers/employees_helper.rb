#  Copyright (c) 2006-2017, Puzzle ITC GmbH. This file is part of
#  PuzzleTime and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/puzzletime.


module EmployeesHelper
  def format_employee_current_percent(employee)
    value = employee.current_percent
    case value
    when nil then 'keine'
    when value.to_i then "#{value.to_i} %"
    else "#{value} %"
    end
  end

  def multiple_check_box(object_name, field, value)
    object = instance_variable_get("@#{object_name}")
    check_box_tag "#{object_name}[#{field}][]", value, object.send(field).include?(value)
  end

  def format_current_employment_roles(employee, separator = ', ')
    employment = employee.current_employment
    return if employment.nil?
    safe_join(employment.employment_roles_employments.map do |ere|
      [ere.employment_role.name,
       ere.employment_role_level.present? ? ere.employment_role_level.name : nil,
       format_percent(ere.percent)].compact.join(' ')
    end, separator)
  end

  def version_author(version)
    if version.version_author.present?
      employee = Employee.where(id: version.version_author).first
      employee.to_s if employee.present?
    end
  end

  def version_changes(version)
    safe_join(
      [
        version_title(version),
        version_changed(version)
      ]
    )
  end

  def version_title(version)
    model = version.item_type.parameterize
    event = version.event
    content_tag(:h4, t("version.model.#{event}.#{model}", id: version.item_id))
  end

  def version_changed(version)
    item_class = version.item_type.constantize

    safe_join(version.changeset) do |attr, (from, to)|
      unless from.blank? && to.blank?
        content_tag(:div, version_attribute_change(item_class, attr, from, to))
      end
    end
  end

  def version_attribute_change(item_class, attr, from, to)
    key = version_attribute_change_key(from, to)
    t("version.attribute_change.#{key}", version_attribute_change_args(item_class, attr, from, to))
  end

  def version_attribute_change_key(from, to)
    if from.present? && to.present?
      'from_to'
    elsif from.present?
      'from'
    elsif to.present?
      'to'
    end
  end

  def version_attribute_change_args(item_class, attr, from, to)
    attr_s = attr.to_s
    if item_class.defined_enums[attr_s]
      to = item_class.human_attribute_name([attr_s.pluralize, to].join('.'))
    end

    { attr: item_class.human_attribute_name(attr),
      model_ref: t("version.model_reference.#{item_class.name.parameterize}"),
      from: f(from),
      to: f(to) }
  end
end
