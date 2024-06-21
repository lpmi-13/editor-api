# frozen_string_literal: true

FactoryBot.define do
  factory :invitation do
    email_address { 'teacher@example.com' }
    school factory: :verified_school
  end
end
