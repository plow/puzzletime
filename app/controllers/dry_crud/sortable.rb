#  Copyright (c) 2006-2017, Puzzle ITC GmbH. This file is part of
#  PuzzleTime and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/puzzletime.

module DryCrud
  # Sort functionality for the index table.
  # Define a default sort expression that is always appended to the
  # current sort params with the class attribute +default_sort+.
  module Sortable
    extend ActiveSupport::Concern

    included do
      class_attribute :sort_mappings_with_indifferent_access
      self.sort_mappings = {}

      class_attribute :default_sort

      helper_method :sortable?

      prepend Prepends
    end

    # Class methods for sorting.
    module ClassMethods
      # Define a map of (virtual) attributes to SQL order expressions.
      # May be used for sorting table columns that do not appear directly
      # in the database table. E.g., map city_id: 'cities.name' to
      # sort the displayed city names.
      def sort_mappings=(hash)
        self.sort_mappings_with_indifferent_access =
          hash.with_indifferent_access
      end
    end

    # Prepended methods for sorting.
    module Prepends
      private

      # Enhance the list entries with an optional sort order.
      def list_entries
        sortable = sortable?(params[:sort])
        if sortable || default_sort
          clause = [sortable ? sort_expression : nil, default_sort]
          super.reorder(clause.compact.join(', '))
        else
          super
        end
      end

      # Return the sort expression to be used in the list query.
      def sort_expression
        col = sort_mappings_with_indifferent_access[params[:sort]] ||
              "#{model_class.table_name}.#{params[:sort]}"
        "#{col} #{sort_dir}"
      end

      # The sort direction, either 'asc' or 'desc'.
      def sort_dir
        if number_null_order?
          params[:sort_dir] == 'desc' ? 'DESC NULLS LAST' : 'ASC NULLS FIRST'
        else
          params[:sort_dir] == 'desc' ? 'DESC' : 'ASC'
        end
      end

      # Returns true if the passed attribute is sortable.
      def sortable?(attr)
        attr.present? && (
        model_class.column_names.include?(attr.to_s) ||
        sort_mappings_with_indifferent_access.include?(attr))
      end

      def number_null_order?
        type = model_class.columns_hash[params[:sort]].try(:type)
        !sort_mappings_with_indifferent_access.key?(params[:sort]) &&
          type == :integer || type == :float
      end
    end
  end
end
