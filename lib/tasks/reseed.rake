#  Copyright (c) 2006-2018, Puzzle ITC GmbH. This file is part of
#  PuzzleTime and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/puzzletime.


namespace :db do

  desc "Empties the database and loads the seeds again"
  task :reseed => ['db:clobber', 'db:schema:load', 'db:seed']

  desc "Completely empties the database"
  task :clobber => :environment do
    con = ActiveRecord::Base.connection
    ActiveRecord::Base.transaction do
      con.tables.each do |t|
        con.drop_table(t, force: :cascade)
      end
    end
  end
end
