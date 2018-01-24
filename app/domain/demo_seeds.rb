#  Copyright (c) 2006-2017, Puzzle ITC GmbH. This file is part of
#  PuzzleTime and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/puzzletime.


module DemoSeeds
  # Access the active Invoicing class here
  cattr_accessor :instance

  def self.init
    if demo_instance?
      ReseedJob.new.schedule if Delayed::Job.table_exists?
    end
  end

  private

  def self.demo_instance?
    ENV['DEMO_INSTANCE'] == '1'
  end
end
