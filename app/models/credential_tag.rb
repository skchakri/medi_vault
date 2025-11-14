# frozen_string_literal: true

class CredentialTag < ApplicationRecord
  # Associations
  belongs_to :credential, counter_cache: :tags_count
  belongs_to :tag, counter_cache: :usage_count

  # Validations
  validates :credential_id, uniqueness: { scope: :tag_id, message: "already has this tag" }
end
