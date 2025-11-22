# frozen_string_literal: true

class AiEmbedding < ApplicationRecord
  belongs_to :source, polymorphic: true, optional: true

  validates :provider, :model, :vector, :dim, presence: true
  validates :dim, numericality: { greater_than: 0 }

  def cosine_similarity(other_vector)
    return 0.0 if vector.blank? || other_vector.blank?

    a = vector.map(&:to_f)
    b = other_vector.map(&:to_f)
    min_size = [a.size, b.size].min
    return 0.0 if min_size.zero?

    a = a.first(min_size)
    b = b.first(min_size)
    dot = a.zip(b).sum { |x, y| x * y }
    norm_a = Math.sqrt(a.sum { |x| x**2 })
    norm_b = Math.sqrt(b.sum { |x| x**2 })
    return 0.0 if norm_a.zero? || norm_b.zero?

    dot / (norm_a * norm_b)
  end
end
