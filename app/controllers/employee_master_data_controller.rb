class EmployeeMasterDataController < ApplicationController

  delegate :model_class, to: 'self.class'
  class << self
    def model_class
      Employee
    end
  end

  def index
    authorize!(:read, Employee)
    @employees = list_entries
  end

  def show
    @employee = Employee.find(params[:id])
    authorize!(:read, @employee)
  end

  private

  def list_entries
    Employee.select('employees.*, ' \
                    'em.percent AS current_percent_value, ' \
                    'CONCAT(lastname, \' \', firstname) AS fullname')
            .employed_ones(Period.current_day)
            .joins('LEFT JOIN departments ON departments.id = employees.department_id')
            .includes(:department, current_employment: {
                        employment_roles_employments: [:employment_role, :employment_role_level]
                      })
            .list
  end

  # Must be included after the #list_entries method is defined.
  include DryCrud::Searchable
  include DryCrud::Sortable

  # Must be defined after searchable/sortable modules have been included.
  self.search_columns = ['lastname', 'firstname', 'shortname', 'departments.name']
  self.sort_mappings_with_indifferent_access = {
    department: 'departments.name',
    fullname: 'fullname',
    current_percent_value: 'current_percent_value'
  }.with_indifferent_access

end
