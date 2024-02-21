# frozen_string_literal: true

lesson, user = @lesson_with_user

json.call(
  lesson,
  :id,
  :school_id,
  :school_class_id,
  :user_id,
  :name,
  :visibility,
  :due_date,
  :created_at,
  :archived_at,
  :updated_at
)

json.user_name(user&.name)
