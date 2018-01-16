#  Copyright (c) 2006-2018, Puzzle ITC GmbH. This file is part of
#  PuzzleTime and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/puzzletime.


class ReseedJob < CronJob
  self.cron_expression = '34 3 * * *'

  def perform
    system 'bundle exec rake db:reseed'
  end
end
