# frozen_string_literal: true

class Project < ApplicationRecord
  belongs_to :parent, optional: true, class_name: :Project, foreign_key: :remixed_from_id, inverse_of: :remixes
  has_many :remixes, dependent: :nullify, class_name: :Project, foreign_key: :remixed_from_id, inverse_of: :parent
  has_many :components, -> { order(default: :desc, name: :asc) }, dependent: :destroy, inverse_of: :project
  has_many :project_errors, dependent: :nullify
  has_many_attached :images

  accepts_nested_attributes_for :components

  before_validation :check_unique_not_null, on: :create

  validates :identifier, presence: true, uniqueness: { scope: :locale }
  validate :identifier_cannot_be_taken_by_another_user
  validates :locale, presence: true, unless: :user_id

  scope :internal_projects, -> { where(user_id: nil) }

  private

  def check_unique_not_null
    self.identifier ||= PhraseIdentifier.generate
  end

  def identifier_cannot_be_taken_by_another_user
    return if Project.where(identifier: self.identifier).where.not(user_id:).empty?

    errors.add(:identifier, "can't be taken by another user")
  end
end
