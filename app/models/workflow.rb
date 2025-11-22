# frozen_string_literal: true

class Workflow < ApplicationRecord
  STATUSES = %w[draft active archived].freeze

  belongs_to :created_by, class_name: 'User', optional: true

  validates :name, presence: true
  validates :status, inclusion: { in: STATUSES }
  validate :nodes_and_edges_are_arrays

  def tool_nodes
    Array(nodes)
  end

  def connections
    Array(edges)
  end

  private

  def nodes_and_edges_are_arrays
    errors.add(:nodes, 'must be an array') unless nodes.is_a?(Array)
    errors.add(:edges, 'must be an array') unless edges.is_a?(Array)
  end
end
