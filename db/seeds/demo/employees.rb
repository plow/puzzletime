#  Copyright (c) 2006-2017, Puzzle ITC GmbH. This file is part of
#  PuzzleTime and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/puzzletime.


employees = Employee.seed(:shortname,
  { firstname: 'Bereichs-',
    lastname: 'Leiter',
    shortname: 'BL',
    passwd: '86f7e437faa5a7fce15d1ddcb9eaeaea377667b8', # a
    email: 'bl@puzzletime.ch',
    management: true },

  { firstname: 'Projekt-',
    lastname: 'Leiter',
    shortname: 'PL',
    passwd: '86f7e437faa5a7fce15d1ddcb9eaeaea377667b8', # a
    email: 'pl@puzzletime.ch',
    management: false },

  { firstname: 'Mit-',
    lastname: 'Arbeiter',
    shortname: 'MA',
    passwd: '86f7e437faa5a7fce15d1ddcb9eaeaea377667b8', # a
    email: 'ma@puzzletime.ch',
    management: false }
)

Employment.seed(:employee_id, :start_date,
  { employee_id: employees[0].id,
    percent: 100,
    start_date: Date.today - 2 },

  { employee_id: employees[1].id,
    percent: 90,
    start_date: Date.today - 1 },

  { employee_id: employees[2].id,
    percent: 80,
    start_date: Date.today },
)
