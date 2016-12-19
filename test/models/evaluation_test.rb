# encoding: utf-8

require 'test_helper'

class EvaluationTest < ActiveSupport::TestCase
  def setup
    @period_week = Period.new('4.12.2006', '10.12.2006')
    @period_month = Period.new('1.12.2006', '31.12.2006')
    @period_day = Period.new('4.12.2006', '4.12.2006')
  end

  def test_clients
    @evaluation = ClientsEval.new
    assert ! @evaluation.absences?
    assert ! @evaluation.for?(employees(:pascal))
    assert ! @evaluation.total_details

    divisions = @evaluation.divisions.list
    assert_equal 3, divisions.size
    assert_equal work_items(:pbs), divisions[0]
    assert_equal work_items(:puzzle), divisions[1]
    assert_equal work_items(:swisstopo), divisions[2]

    assert_sum_times 0, 20, 32, 33, work_items(:puzzle)
    assert_sum_times 3, 10, 21, 21, work_items(:swisstopo)

    assert_equal({ work_items(:swisstopo).id => { hours: 3.0, billable_hours: 0.0 } },
                 @evaluation.sum_times_grouped(@period_day))
    assert_equal({ work_items(:puzzle).id => { hours: 20.0, billable_hours: 20.0 },
                   work_items(:swisstopo).id => { hours: 10.0, billable_hours: 7.0 } },
                 @evaluation.sum_times_grouped(@period_week))
    assert_equal({ work_items(:puzzle).id => { hours: 32.0, billable_hours: 22.0 },
                   work_items(:swisstopo).id => { hours: 21.0, billable_hours: 18.0 } },
                 @evaluation.sum_times_grouped(@period_month))

    assert_sum_total_times({ hours: 3.0, billable_hours: 0.0 },
                           { hours: 30.0, billable_hours: 27.0 },
                           { hours: 53.0, billable_hours: 40.0 },
                           { hours: 54.0, billable_hours: 41.0 })
  end

  def test_clients_detail_puzzle
    @evaluation = ClientsEval.new
    @evaluation.set_division_id work_items(:puzzle).id
    assert_sum_times 0, 20, 32, 33
    assert_count_times 0, 3, 5, 6
  end

  def test_clients_detail_swisstopo
    @evaluation = ClientsEval.new
    @evaluation.set_division_id work_items(:swisstopo).id

    assert_sum_times 3, 10, 21, 21
    assert_count_times 1, 2, 3, 3
  end

  def test_employees
    @evaluation = EmployeesEval.new
    assert ! @evaluation.absences?
    assert ! @evaluation.for?(employees(:pascal))
    assert ! @evaluation.total_details

    divisions = @evaluation.divisions
    assert_equal 3, divisions.size

    assert_sum_times 0, 18, 18, 18, employees(:mark)
    assert_sum_times 0, 9, 30, 30, employees(:lucien)
    assert_sum_times 3, 3, 5, 6, employees(:pascal)

    assert_equal({ employees(:pascal).id => 3.0 },
                 @evaluation.sum_times_grouped(@period_day))
    assert_equal({ employees(:mark).id => 18.0, employees(:lucien).id => 9.0, employees(:pascal).id => 3.0 },
                 @evaluation.sum_times_grouped(@period_week))
    assert_equal({ employees(:mark).id => 18.0, employees(:lucien).id => 30.0, employees(:pascal).id => 5.0 },
                 @evaluation.sum_times_grouped(@period_month))

    assert_sum_total_times 3.0, 30.0, 53.0, 54.0
  end

  def test_employee_detail_mark
    @evaluation = EmployeesEval.new
    @evaluation.set_division_id employees(:mark).id

    assert_sum_times 0, 18, 18, 18
    assert_count_times 0, 3, 3, 3
  end

  def test_employee_detail_lucien
    @evaluation = EmployeesEval.new
    @evaluation.set_division_id employees(:lucien).id

    assert_sum_times 0, 9, 30, 30
    assert_count_times 0, 1, 3, 3
  end

  def test_employee_detail_pascal
    @evaluation = EmployeesEval.new
    @evaluation.set_division_id employees(:pascal).id

    assert_sum_times 3, 3, 5, 6
    assert_count_times 1, 1, 2, 3
  end

  def test_absences
    @evaluation = AbsencesEval.new
    assert @evaluation.absences?
    assert ! @evaluation.for?(employees(:pascal))
    assert ! @evaluation.total_details

    divisions = @evaluation.divisions
    assert_equal 3, divisions.size

    assert_sum_times 0, 8, 8, 8, employees(:mark)
    assert_sum_times 0, 0, 12, 12, employees(:lucien)
    assert_sum_times 0, 4, 17, 17, employees(:pascal)

    assert_equal({},
                 @evaluation.sum_times_grouped(@period_day))
    assert_equal({ employees(:mark).id => 8.0, employees(:pascal).id => 4.0 },
                 @evaluation.sum_times_grouped(@period_week))
    assert_equal({ employees(:mark).id => 8.0, employees(:lucien).id => 12.0, employees(:pascal).id => 17.0 },
                 @evaluation.sum_times_grouped(@period_month))

    assert_sum_total_times 0.0, 12.0, 37.0, 37.0
  end

  def test_absences_detail_mark
    @evaluation = AbsencesEval.new
    @evaluation.set_division_id employees(:mark).id

    assert_sum_times 0, 8, 8, 8
    assert_count_times 0, 1, 1, 1
  end

  def test_absences_detail_lucien
    @evaluation = AbsencesEval.new
    @evaluation.set_division_id employees(:lucien).id

    assert_sum_times 0, 0, 12, 12
    assert_count_times 0, 0, 1, 1
  end

  def test_absences_detail_pascal
    @evaluation = AbsencesEval.new
    @evaluation.set_division_id employees(:pascal).id

    assert_sum_times 0, 4, 17, 17
    assert_count_times 0, 1, 2, 2
  end

  def test_managed_work_items_pascal
    @evaluation = ManagedOrdersEval.new(employees(:pascal))
    assert_managed employees(:pascal)

    divisions = @evaluation.divisions.list
    assert_equal 0, divisions.size
 end

  def test_managed_work_items_mark
    @evaluation = ManagedOrdersEval.new(employees(:mark))
    assert_managed employees(:mark)

    divisions = @evaluation.divisions.list
    assert_equal 1, divisions.size
    assert_equal work_items(:allgemein).id, divisions.first.id

    assert_sum_times 0, 14, 14, 15, work_items(:allgemein)

    assert_equal({},
                 @evaluation.sum_times_grouped(@period_day))
    assert_equal({ work_items(:allgemein).id => { hours: 14.0, billable_hours: 14.0 } },
                 @evaluation.sum_times_grouped(@period_week))
    assert_equal({ work_items(:allgemein).id => { hours: 14.0, billable_hours: 14.0 } },
                 @evaluation.sum_times_grouped(@period_month))

    assert_sum_total_times({ hours: 0.0, billable_hours: 0.0 },
                           { hours: 14.0, billable_hours: 14.0 },
                           { hours: 14.0, billable_hours: 14.0 },
                           { hours: 15.0, billable_hours: 15.0 })
  end

  def test_managed_work_items_mark_details
    @evaluation = ManagedOrdersEval.new(employees(:mark))
    @evaluation.set_division_id work_items(:allgemein).id

    assert_sum_times 0, 14, 14, 15
    assert_count_times 0, 2, 2, 3
  end

  def test_managed_work_items_lucien
    @evaluation = ManagedOrdersEval.new(employees(:lucien))
    assert_managed employees(:lucien)
    divisions = @evaluation.divisions
    assert_equal 2, divisions.size
    assert_equal work_items(:hitobito_demo).id, divisions[0].id
    assert_equal work_items(:puzzletime).id, divisions[1].id

    assert_sum_times 0, 6, 18, 18, work_items(:puzzletime)

    assert_equal({},
                 @evaluation.sum_times_grouped(@period_day))
    assert_equal({ work_items(:puzzletime).id => { hours: 6.0, billable_hours: 6.0 } },
                 @evaluation.sum_times_grouped(@period_week))
    assert_equal({ work_items(:puzzletime).id => { hours: 18.0, billable_hours: 8.0 } },
                 @evaluation.sum_times_grouped(@period_month))

    assert_sum_total_times({ hours: 0.0, billable_hours: 0.0 },
                           { hours: 6.0, billable_hours: 6.0 },
                           { hours: 18.0, billable_hours: 8.0 },
                           { hours: 18.0, billable_hours: 8.0 })
  end

  def test_managed_work_items_lucien_details
    @evaluation = ManagedOrdersEval.new(employees(:lucien))
    @evaluation.set_division_id work_items(:puzzletime).id

    assert_sum_times 0, 6, 18, 18
    assert_count_times 0, 1, 3, 3
  end

  def assert_managed(user)
    assert ! @evaluation.absences?
    assert ! @evaluation.for?(user)
    assert ! @evaluation.total_details
  end

  def test_client_work_items
    @evaluation = ClientWorkItemsEval.new(clients(:puzzle).id)
    assert ! @evaluation.absences?
    assert ! @evaluation.for?(employees(:mark))
    assert @evaluation.total_details

    divisions = @evaluation.divisions.list
    assert_equal 4, divisions.size
    assert_equal work_items(:allgemein), divisions[0]
    assert_equal work_items(:hitobito), divisions[1]
    assert_equal work_items(:intern), divisions[2]
    assert_equal work_items(:puzzletime), divisions[3]

    assert_sum_times 0, 20, 32, 33
    assert_count_times 0, 3, 5, 6
    assert_sum_times 0, 14, 14, 15, work_items(:allgemein)
    assert_sum_times 0, 6, 18, 18, work_items(:puzzletime)

    assert_equal({},
                 @evaluation.sum_times_grouped(@period_day))
    assert_equal({ work_items(:allgemein).id => { hours: 14.0, billable_hours: 14.0 },
                   work_items(:puzzletime).id => { hours: 6.0, billable_hours: 6.0 } },
                 @evaluation.sum_times_grouped(@period_week))
    assert_equal({ work_items(:allgemein).id => { hours: 14.0, billable_hours: 14.0 },
                   work_items(:puzzletime).id => { hours: 18.0, billable_hours: 8.0 } },
                 @evaluation.sum_times_grouped(@period_month))

    assert_sum_total_times({ hours: 0.0, billable_hours: 0.0 },
                           { hours: 20.0, billable_hours: 20.0 },
                           { hours: 32.0, billable_hours: 22.0 },
                           { hours: 33.0, billable_hours: 23.0 })
  end

  def test_client_work_items_detail
    @evaluation = ClientWorkItemsEval.new(clients(:puzzle).id)

    @evaluation.set_division_id(work_items(:allgemein).id)
    assert_sum_times 0, 14, 14, 15
    assert_count_times 0, 2, 2, 3

    @evaluation.set_division_id(work_items(:puzzletime).id)
    assert_sum_times 0, 6, 18, 18
    assert_count_times 0, 1, 3, 3
  end

  def test_employee_work_items_pascal
    @evaluation = EmployeeWorkItemsEval.new(employees(:pascal).id)
    assert ! @evaluation.absences?
    assert @evaluation.for?(employees(:pascal))
    assert @evaluation.total_details

    divisions = @evaluation.divisions.list.to_a
    assert_equal 2, divisions.size
    assert_equal work_items(:puzzle).id, divisions[0].id
    assert_equal work_items(:swisstopo).id, divisions[1].id

    assert_sum_times 0, 0, 2, 3, work_items(:puzzle)
    assert_sum_times 3, 3, 3, 3, work_items(:swisstopo)

    assert_equal({ work_items(:swisstopo).id => 3.0 },
                 @evaluation.sum_times_grouped(@period_day))
    assert_equal({ work_items(:swisstopo).id => 3.0 },
                 @evaluation.sum_times_grouped(@period_week))
    assert_equal({ work_items(:puzzle).id => 2.0, work_items(:swisstopo).id => 3.0 },
                 @evaluation.sum_times_grouped(@period_month))

    assert_sum_total_times 3.0, 3.0, 5.0, 6.0
  end

  def test_employee_work_items_pascal_detail
    @evaluation = EmployeeSubWorkItemsEval.new(work_items(:puzzle).id, employees(:pascal).id)

    @evaluation.set_division_id(work_items(:allgemein).id)
    assert_sum_times 0, 0, 0, 1
    assert_count_times 0, 0, 0, 1

    @evaluation.set_division_id(work_items(:puzzletime).id)
    assert_sum_times 0, 0, 2, 2
    assert_count_times 0, 0, 1, 1
  end

  def test_employee_work_items_mark
    @evaluation = EmployeeWorkItemsEval.new(employees(:mark).id)
    assert ! @evaluation.absences?
    assert @evaluation.for?(employees(:mark))
    assert @evaluation.total_details

    divisions = @evaluation.divisions.list.to_a
    assert_equal 2, divisions.size
    assert_equal work_items(:puzzle).id, divisions[0].id
    assert_equal work_items(:swisstopo).id, divisions[1].id

    assert_sum_times 0, 11, 11, 11, work_items(:puzzle)
    assert_sum_times 0, 7, 7, 7, work_items(:swisstopo)

    assert_equal({},
                 @evaluation.sum_times_grouped(@period_day))
    assert_equal({ work_items(:puzzle).id => 11.0, work_items(:swisstopo).id => 7.0 },
                 @evaluation.sum_times_grouped(@period_week))
    assert_equal({ work_items(:puzzle).id => 11.0, work_items(:swisstopo).id => 7.0 },
                 @evaluation.sum_times_grouped(@period_month))

    assert_sum_total_times 0.0, 18.0, 18.0, 18.0
  end

  def test_employee_work_items_mark_detail
    @evaluation = EmployeeSubWorkItemsEval.new(work_items(:puzzle).id, employees(:mark).id)
    @evaluation.set_division_id(work_items(:allgemein).id)
    assert_sum_times 0, 5, 5, 5
    assert_count_times 0, 1, 1, 1
  end

  def test_employee_work_items_lucien
    @evaluation = EmployeeWorkItemsEval.new(employees(:lucien).id)
    assert ! @evaluation.absences?
    assert @evaluation.for?(employees(:lucien))
    assert @evaluation.total_details

    divisions = @evaluation.divisions.list.to_a
    assert_equal 2, divisions.size
    assert_equal work_items(:puzzle).id, divisions[0].id
    assert_equal work_items(:swisstopo).id, divisions[1].id

    assert_sum_times 0, 9, 19, 19, work_items(:puzzle)
    assert_sum_times 0, 0, 11, 11, work_items(:swisstopo)

    assert_equal({},
                 @evaluation.sum_times_grouped(@period_day))
    assert_equal({ work_items(:puzzle).id => 9.0 },
                 @evaluation.sum_times_grouped(@period_week))
    assert_equal({ work_items(:swisstopo).id => 11.0, work_items(:puzzle).id => 19.0 },
                 @evaluation.sum_times_grouped(@period_month))

    assert_sum_total_times 0.0, 9.0, 30.0, 30.0
  end

  def test_employee_work_items_lucien_detail
    @evaluation = EmployeeSubWorkItemsEval.new(work_items(:swisstopo).id, employees(:lucien).id)
    @evaluation.set_division_id(work_items(:webauftritt).id)
    assert_sum_times 0, 0, 11, 11
    assert_count_times 0, 0, 1, 1
  end

  def test_project_employees_allgemein
    @evaluation = WorkItemEmployeesEval.new(work_items(:allgemein).id)
    assert ! @evaluation.absences?
    assert ! @evaluation.for?(employees(:pascal))
    assert @evaluation.total_details

    divisions = @evaluation.divisions.list.to_a
    assert_equal 3, divisions.size
    assert_equal employees(:mark), divisions[0]
    assert_equal employees(:lucien), divisions[1]
    assert_equal employees(:pascal), divisions[2]

    assert_sum_times 0, 5, 5, 5, employees(:mark)
    assert_sum_times 0, 9, 9, 9, employees(:lucien)
    assert_sum_times 0, 0, 0, 1, employees(:pascal)

    assert_equal({},
                 @evaluation.sum_times_grouped(@period_day))
    assert_equal({ employees(:mark).id => { hours: 5.0, billable_hours: 5.0 },
                   employees(:lucien).id => { hours: 9.0, billable_hours: 9.0 } },
                 @evaluation.sum_times_grouped(@period_week))
    assert_equal({ employees(:mark).id => { hours: 5.0, billable_hours: 5.0 },
                   employees(:lucien).id => { hours: 9.0, billable_hours: 9.0 } },
                 @evaluation.sum_times_grouped(@period_month))

    assert_sum_total_times({ hours: 0.0, billable_hours: 0.0 },
                           { hours: 14.0, billable_hours: 14.0 },
                           { hours: 14.0, billable_hours: 14.0 },
                           { hours: 15.0, billable_hours: 15.0 })
  end

  def test_project_employees_allgemein_detail
    @evaluation = WorkItemEmployeesEval.new(work_items(:allgemein).id)

    @evaluation.set_division_id(employees(:mark).id)
    assert_sum_times 0, 5, 5, 5
    assert_count_times 0, 1, 1, 1

    @evaluation.set_division_id(employees(:pascal).id)
    assert_sum_times 0, 0, 0, 1
    assert_count_times 0, 0, 0, 1
  end

  def test_project_employees_puzzletime
    @evaluation = WorkItemEmployeesEval.new(work_items(:puzzletime).id)
    assert ! @evaluation.absences?
    assert ! @evaluation.for?(employees(:pascal))
    assert @evaluation.total_details

    divisions = @evaluation.divisions.list.to_a
    assert_equal 3, divisions.size
    assert_equal employees(:mark), divisions[0]
    assert_equal employees(:lucien), divisions[1]
    assert_equal employees(:pascal), divisions[2]

    assert_sum_times 0, 6, 6, 6, employees(:mark)
    assert_sum_times 0, 0, 10, 10, employees(:lucien)
    assert_sum_times 0, 0, 2, 2, employees(:pascal)

    assert_equal({},
                 @evaluation.sum_times_grouped(@period_day))
    assert_equal({ employees(:mark).id => { hours: 6.0, billable_hours: 6.0 } },
                 @evaluation.sum_times_grouped(@period_week))
    assert_equal({ employees(:mark).id => { hours: 6.0, billable_hours: 6.0 },
                   employees(:pascal).id => { hours: 2.0, billable_hours: 2.0 },
                   employees(:lucien).id => { hours: 10.0, billable_hours: 0.0 } },
                 @evaluation.sum_times_grouped(@period_month))

    assert_sum_total_times({ hours: 0.0, billable_hours: 0.0 },
                           { hours: 6.0, billable_hours: 6.0 },
                           { hours: 18.0, billable_hours: 8.0 },
                           { hours: 18.0, billable_hours: 8.0 })
  end

  def test_project_employees_puzzletime_detail
    @evaluation = WorkItemEmployeesEval.new(work_items(:puzzletime).id)

    @evaluation.set_division_id(employees(:pascal).id)
    assert_sum_times 0, 0, 2, 2
    assert_count_times 0, 0, 1, 1
  end


  def test_project_employees_webauftritt
    @evaluation = WorkItemEmployeesEval.new(work_items(:webauftritt).id)
    assert ! @evaluation.absences?
    assert ! @evaluation.for?(employees(:lucien))
    assert @evaluation.total_details

    divisions = @evaluation.divisions.list.to_a
    assert_equal 3, divisions.size
    assert_equal employees(:mark), divisions[0]
    assert_equal employees(:lucien), divisions[1]
    assert_equal employees(:pascal), divisions[2]

    assert_sum_times 0, 7, 7, 7, employees(:mark)
    assert_sum_times 0, 0, 11, 11, employees(:lucien)
    assert_sum_times 3, 3, 3, 3, employees(:pascal)

    assert_equal({ employees(:pascal).id => { hours: 3.0, billable_hours: 0.0 } },
                 @evaluation.sum_times_grouped(@period_day))
    assert_equal({ employees(:pascal).id => { hours: 3.0, billable_hours: 0.0 },
                   employees(:mark).id => { hours: 7.0, billable_hours: 7.0 } },
                 @evaluation.sum_times_grouped(@period_week))
    assert_equal({ employees(:lucien).id => { hours: 11.0, billable_hours: 11.0 },
                   employees(:pascal).id => { hours: 3.0, billable_hours: 0.0 },
                   employees(:mark).id => { hours: 7.0, billable_hours: 7.0 } },
                 @evaluation.sum_times_grouped(@period_month))

    assert_sum_total_times({ hours: 3.0, billable_hours: 0.0 },
                           { hours: 10.0, billable_hours: 7.0 },
                           { hours: 21.0, billable_hours: 18.0 },
                           { hours: 21.0, billable_hours: 18.0 })
  end

  def test_project_employees_webauftritt_detail
    @evaluation = WorkItemEmployeesEval.new(work_items(:webauftritt).id)

    @evaluation.set_division_id(employees(:lucien).id)
    assert_sum_times 0, 0, 11, 11
    assert_count_times 0, 0, 1, 1
  end

  def test_employee_absences_pascal
    @evaluation = EmployeeAbsencesEval.new(employees(:pascal).id)
    assert @evaluation.absences?
    assert @evaluation.for?(employees(:pascal))
    assert @evaluation.total_details

    divisions = @evaluation.divisions.list
    assert_equal 2, divisions.size
    assert_equal absences(:doctor), divisions[0]
    assert_equal absences(:vacation), divisions[1]

    assert_sum_times 0, 4, 17, 17
    assert_sum_times 0, 4, 4, 4, absences(:vacation)
    assert_sum_times 0, 0, 13, 13, absences(:doctor)

    assert_equal({},
                 @evaluation.sum_times_grouped(@period_day))
    assert_equal({ absences(:vacation).id => 4.0 },
                 @evaluation.sum_times_grouped(@period_week))
    assert_equal({ absences(:vacation).id => 4.0, absences(:doctor).id => 13.0 },
                 @evaluation.sum_times_grouped(@period_month))

    assert_sum_total_times 0.0, 4.0, 17.0, 17.0
  end

  def test_employee_absences_pascal_detail
    @evaluation = EmployeeAbsencesEval.new(employees(:pascal).id)

    @evaluation.set_division_id(absences(:vacation).id)
    assert_sum_times 0, 4, 4, 4
    assert_count_times 0, 1, 1, 1

    @evaluation.set_division_id(absences(:doctor).id)
    assert_sum_times 0, 0, 13, 13
    assert_count_times 0, 0, 1, 1
  end

  def test_employee_absences_mark
    @evaluation = EmployeeAbsencesEval.new(employees(:mark).id)
    assert @evaluation.absences?
    assert @evaluation.for?(employees(:mark))
    assert @evaluation.total_details

    divisions = @evaluation.divisions.list
    assert_equal 1, divisions.size
    assert_equal absences(:civil_service), divisions[0]

    assert_sum_times 0, 8, 8, 8
    assert_sum_times 0, 8, 8, 8, absences(:civil_service)

    assert_equal({},
                 @evaluation.sum_times_grouped(@period_day))
    assert_equal({ absences(:civil_service).id => 8.0 },
                 @evaluation.sum_times_grouped(@period_week))
    assert_equal({ absences(:civil_service).id => 8.0 },
                 @evaluation.sum_times_grouped(@period_month))

    assert_sum_total_times 0.0, 8.0, 8.0, 8.0
  end

  def test_employee_absences_mark_detail
    @evaluation = EmployeeAbsencesEval.new(employees(:mark).id)

    @evaluation.set_division_id(absences(:civil_service).id)
    assert_sum_times 0, 8, 8, 8
    assert_count_times 0, 1, 1, 1
  end

  def test_employee_absences_lucien
    @evaluation = EmployeeAbsencesEval.new(employees(:lucien).id)
    assert @evaluation.absences?
    assert @evaluation.for?(employees(:lucien))
    assert @evaluation.total_details

    divisions = @evaluation.divisions.list
    assert_equal 1, divisions.size
    assert_equal absences(:doctor), divisions[0]

    assert_sum_times 0, 0, 12, 12
    assert_sum_times 0, 0, 12, 12, absences(:doctor)

    assert_equal({},
                 @evaluation.sum_times_grouped(@period_day))
    assert_equal({},
                 @evaluation.sum_times_grouped(@period_week))
    assert_equal({ absences(:doctor).id => 12.0 },
                 @evaluation.sum_times_grouped(@period_month))

    assert_sum_total_times 0.0, 0.0, 12.0, 12.0
  end

  def test_employee_absences_lucien_detail
    @evaluation = EmployeeAbsencesEval.new(employees(:lucien).id)

    @evaluation.set_division_id(absences(:doctor).id)
    assert_sum_times 0, 0, 12, 12
    assert_count_times 0, 0, 1, 1
  end

  def assert_sum_times(day, week, month, all, div = nil)
    assert_equal day, @evaluation.sum_times(@period_day, div)
    assert_equal week, @evaluation.sum_times(@period_week, div)
    assert_equal month, @evaluation.sum_times(@period_month, div)
    assert_equal all, @evaluation.sum_times(nil, div)
  end

  def assert_sum_total_times(day, week, month, all)
    assert_equal day, @evaluation.sum_total_times(@period_day)
    assert_equal week, @evaluation.sum_total_times(@period_week)
    assert_equal month, @evaluation.sum_total_times(@period_month)
    assert_equal all, @evaluation.sum_total_times(nil)
  end

  def assert_count_times(day, week, month, all)
    assert_equal day, @evaluation.times(@period_day).size
    assert_equal week, @evaluation.times(@period_week).size
    assert_equal month, @evaluation.times(@period_month).size
    assert_equal all, @evaluation.times(nil).size
  end
end
