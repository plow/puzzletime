#  Copyright (c) 2006-2017, Puzzle ITC GmbH. This file is part of
#  PuzzleTime and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/puzzletime.

clients = WorkItem.seed(:shortname, :parent_id,
  { shortname: 'PITC',
    name: 'Puzzle ITC' },

  { shortname: 'SWIS',
    name: 'Swisscom AG' },

  { shortname: 'BLS',
    name: 'BLS AG' }
)

Client.seed(:work_item_id,
  { work_item_id: clients[0].id },

  { work_item_id: clients[1].id,
    sector_id: Sector.find_by_name('Verwaltung').id },

  { work_item_id: clients[2].id,
    sector_id: Sector.find_by_name('Öffentlicher Verkehr').id }
)

categories = WorkItem.seed(:shortname, :parent_id,
  { shortname: 'IPR',
    name: 'Interne Projekte',
    parent_id: clients[0].id },

  { shortname: 'EVE',
    name: 'Events',
    parent_id: clients[0].id }
)

orders = WorkItem.seed(:shortname, :parent_id,
  { shortname: 'PTI',
    name: 'PuzzleTime',
    parent_id: categories[0].id },

  { shortname: 'TTA',
    name: 'Tech Talk',
    parent_id: categories[1].id }
)

Order.seed(:work_item_id,
  # Puzzletime
  { work_item_id: orders[0].id,
    kind_id: OrderKind.find_by_name('Werkvertrag').id,
    responsible_id: Employee.find_by_shortname('BL').id,
    status_id: OrderStatus.find_by_name('Bearbeitung').id,
    department_id: Department.find_by_name('Entwicklung').id,
    order_team_members: %w(BL PL).map {|short| OrderTeamMember.new(employee: Employee.find_by_shortname(short)) }}

)



accounting_posts = WorkItem.seed(:shortname, :parent_id,
  { shortname: 'OPF',
    name: 'Version 1.5',
    parent_id: orders[0].id },

  { shortname: 'ERP',
    name: 'Version ERP',
    parent_id: orders[0].id }
)

AccountingPost.seed(:work_item_id,
  # Puzzletime 1.5
  { work_item_id: accounting_posts[0].id,
    portfolio_item_id: PortfolioItem.find_by_name('Ruby on Rails').id,
    service_id: Service.find_by_name('Software-Entwicklung').id,
    offered_hours: 500,
    billable: false },

  # Puzzletime ERP
  { work_item_id: accounting_posts[1].id,
    portfolio_item_id: PortfolioItem.find_by_name('Ruby on Rails').id,
    service_id: Service.find_by_name('Software-Entwicklung').id,
    offered_hours: 500,
    billable: false }

)