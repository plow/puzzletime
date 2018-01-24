#  Copyright (c) 2006-2017, Puzzle ITC GmbH. This file is part of
#  PuzzleTime and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/puzzletime.

clients = WorkItem.seed(:shortname, :parent_id,
  { shortname: 'PITC',
    name: 'Puzzle ITC' },

  { shortname: 'GVB',
    name: 'Gebäudeversicherung Bern' },

  { shortname: 'BLS',
    name: 'BLS AG' }
)

Client.seed(:work_item_id,
  { work_item_id: clients[0].id,
    sector_id: Sector.find_by_name('Informatik').id },

  { work_item_id: clients[1].id,
    sector_id: Sector.find_by_name('Versicherung').id },

  { work_item_id: clients[2].id,
    sector_id: Sector.find_by_name('Öffentlicher Verkehr').id }
)

categories = WorkItem.seed(:shortname, :parent_id,
  { shortname: 'IPR',
    name: 'Interne Projekte',
    parent_id: clients[0].id }
)

orders = WorkItem.seed(:shortname, :parent_id,
  { shortname: 'PTI',
    name: 'PuzzleTime',
    parent_id: categories[0].id },
  
  { shortname: 'WEAL',
    name: 'Wetteralarm',
    parent_id: clients[1].id}
)

Order.seed(:work_item_id,
  # Puzzletime
  { work_item_id: orders[0].id,
    kind_id: OrderKind.find_by_name('Internes Projekt').id,
    responsible_id: Employee.find_by_shortname('BL').id,
    status_id: OrderStatus.find_by_name('Bearbeitung').id,
    department_id: Department.find_by_name('Entwicklung').id,
    order_team_members: %w(BL PL MA).map {|short| OrderTeamMember.new(employee: Employee.find_by_shortname(short)) }},
    
  # Wetteralarm
  { work_item_id: orders[1].id,
    kind_id: OrderKind.find_by_name('Werkvertrag').id,
    responsible_id: Employee.find_by_shortname('PL').id,
    status_id: OrderStatus.find_by_name('Bearbeitung').id,
    department_id: Department.find_by_name('Entwicklung').id,
    order_team_members: %w(PL MA).map {|short| OrderTeamMember.new(employee: Employee.find_by_shortname(short)) }}
)

work_items = WorkItem.seed(:shortname, :parent_id,
  { shortname: 'WEI',
    name: "Weiterentwicklung #{Date.today.year}",
    parent_id: orders[0].id },
  
  { shortname: 'WEI',
    name: "Weiterentwicklung #{Date.today.year}",
    parent_id: orders[1].id }
)

accounting_posts = AccountingPost.seed(:work_item_id,
  # Puzzletime Weiterentwicklung
  { work_item_id: work_items[0].id,
    portfolio_item_id: PortfolioItem.find_by_name('Ruby on Rails').id,
    service_id: Service.find_by_name('Software-Entwicklung').id,
    offered_hours: 400,
    offered_rate: 0,
    billable: false },

  # Wetteralarm Weiterentwicklung
  { work_item_id: work_items[1].id,
    portfolio_item_id: PortfolioItem.find_by_name('Ruby on Rails').id,
    service_id: Service.find_by_name('Software-Entwicklung').id,
    offered_hours: 600,
    offered_rate: 150,
    billable: true }
)

# create some random ordertime entries for all employees
employees = { "BL" => work_items[0].id, "PL" => work_items[1].id, "MA" => work_items[1].id}
employees.map do |employee_shortname,work_item_id|
  date = Employee.find_by_shortname(employee_shortname).employments.last.start_date
  while date <= Date.today
    unless Holiday.holiday?(date) #skip weekend
      Ordertime.seed(
        { employee_id: Employee.find_by_shortname(employee_shortname).id,
          report_type: "absolute_day",
          work_date: date,
          hours: rand(5.0 .. 10.0).round(2),
          billable: true,
          type: "Ordertime",
          work_item_id: work_item_id }
      )
    end
    date = date + 1
  end
end


# create some planning entries for all employees
employees.map do |employee_shortname,work_item_id|
  employee = Employee.find_by_shortname(employee_shortname)
  date = Date.today.at_beginning_of_week
  while date < (Date.today + 90)
    unless Holiday.holiday?(date) #skip weekend
      Planning.seed(
        { employee_id: employee.id,
          work_item_id: work_item_id,
          date: date,
          percent: employee.employments.last.percent,
          definitive: (date < Date.today + 30) }
      )
      end
    date = date + 1
  end
end
