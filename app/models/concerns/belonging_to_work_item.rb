#  Copyright (c) 2006-2017, Puzzle ITC GmbH. This file is part of
#  PuzzleTime and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/puzzletime.

module BelongingToWorkItem
  extend ActiveSupport::Concern

  included do
    # must be before associations to prevent their destruction
    protect_if :worktimes, 'Dieser Eintrag kann nicht gelöscht werden, da ihm noch Arbeitszeiten zugeordnet sind'

    belongs_to :work_item, validate: true, autosave: true

    has_descendants_through_work_item :worktimes
    has_descendants_through_work_item :plannings

    after_destroy :destroy_exclusive_work_item

    validates :work_item, presence: true

    accepts_nested_attributes_for :work_item, update_only: true

    delegate :name, :shortname, :description, :path_names, :path_shortnames, :label_verbose,
             to: :work_item,
             allow_nil: true

    scope :list, lambda {
      includes(:work_item).
        references(:work_item).
        order('work_items.path_names')
    }
  end

  def to_s
    work_item.to_s if work_item
  end

  private

  def destroy_exclusive_work_item
    if !@item_destroying && exclusive_work_item?
      @item_destroying = true
      work_item.destroy
    end
  end

  def exclusive_work_item?
    true
  end

  module ClassMethods
    def has_ancestor_through_work_item(name)
      memoized_method(name) do |model|
        if new_record?
          work_item.with_ancestors.detect { |a| a.send(name) }.try(name)
        else
          model.joins('LEFT JOIN work_items ON ' \
                      "#{model.table_name}.work_item_id = ANY (work_items.path_ids)").
            find_by('work_items.id = ?', work_item_id)
        end
      end
    end

    def has_descendants_through_work_item(name)
      memoized_method(name) do |model|
        model.joins(:work_item).
          where('? = ANY (work_items.path_ids)', work_item_id)
      end
    end

    private

    def memoized_method(name, &block)
      model = name.to_s.classify.constantize
      define_method(name) do
        instance_variable_get("@#{name}") ||
          instance_variable_set("@#{name}", instance_exec(model, &block))
      end
    end
  end
end
