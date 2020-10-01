#  Copyright (c) 2006-2017, Puzzle ITC GmbH. This file is part of
#  PuzzleTime and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/puzzletime.

class EmploymentRolesController < ManageController
  self.permitted_attrs = [:name, :billable, :level, :employment_role_category_id]

  def list_entries
    super.includes(:employment_role_category)
  end
end
