# frozen_string_literal: true

require 'rake'

if Rails.env.development?
  Rake::Task['projects:create_all'].invoke
  Rake::Task['classroom_management:seed_a_school_with_lessons'].invoke
end
