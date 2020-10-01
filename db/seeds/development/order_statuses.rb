#  Copyright (c) 2006-2017, Puzzle ITC GmbH. This file is part of
#  PuzzleTime and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/puzzletime.

OrderStatus.seed(
  :name,
  { name: 'Bearbeitung',
    style: 'success',
    position: 10 },
  { name: 'Abschluss',
    style: 'info',
    position: 20 },
  { name: 'Abgeschlossen',
    style: 'danger',
    position: 30,
    closed: true },
)
