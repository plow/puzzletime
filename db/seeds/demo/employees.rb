#  Copyright (c) 2006-2017, Puzzle ITC GmbH. This file is part of
#  PuzzleTime and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/puzzletime.


employees = Employee.seed(:shortname,
  { firstname: 'Leiter',
    lastname: 'Bereichs',
    shortname: 'BL',
    passwd: '89e495e7941cf9e40e6980d14a16bf023ccd4c91', # demo
    email: 'bl@puzzletime.ch',
    eval_periods: ["0d", "0m", "-1m", "0y"],
    management: true },

  { firstname: 'Leiter',
    lastname: 'Projekt',
    shortname: 'PL',
    passwd: '89e495e7941cf9e40e6980d14a16bf023ccd4c91', # demo
    email: 'pl@puzzletime.ch',
    eval_periods: ["0d", "0m", "-1m", "0y"],
    management: false },

  { firstname: 'Arbeiter',
    lastname: 'Mit',
    shortname: 'MA',
    passwd: '89e495e7941cf9e40e6980d14a16bf023ccd4c91', # demo
    email: 'ma@puzzletime.ch',
    eval_periods: ["0d", "0m", "-1m", "0y"],
    management: false }
)

Employment.seed(:employee_id, :start_date,
  { employee_id: employees[0].id,
    percent: 100,
    start_date: Date.today.last_month.last_month.at_beginning_of_month },

  { employee_id: employees[1].id,
    percent: 90,
    start_date: Date.today.at_beginning_of_month },

  { employee_id: employees[2].id,
    percent: 80,
    start_date: Date.today.last_month.at_beginning_of_month },
)
