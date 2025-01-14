# frozen_string_literal: true

module ProfileApiMock
  # TODO: Replace with WebMock HTTP stubs once the profile API has been built.

  def stub_profile_api_list_school_owners(user_id:)
    allow(ProfileApiClient).to receive(:list_school_owners).and_return(ids: [user_id])
  end

  def stub_profile_api_invite_school_owner
    allow(ProfileApiClient).to receive(:invite_school_owner)
  end

  def stub_profile_api_remove_school_owner
    allow(ProfileApiClient).to receive(:remove_school_owner)
  end

  def stub_profile_api_list_school_teachers(user_id:)
    allow(ProfileApiClient).to receive(:list_school_teachers).and_return(ids: [user_id])
  end

  def stub_profile_api_remove_school_teacher
    allow(ProfileApiClient).to receive(:remove_school_teacher)
  end

  def stub_profile_api_list_school_students(school:, id:, username: '', name: '')
    now = Time.current.to_fs(:iso8601) # rubocop:disable Naming/VariableNumber
    student = ProfileApiClient::Student.new(
      schoolId: school.id,
      id:, username:, name:,
      createdAt: now, updatedAt: now, discardedAt: nil
    )
    allow(ProfileApiClient).to receive(:list_school_students).and_return([student])
  end

  def stub_profile_api_create_school_student(user_id: SecureRandom.uuid)
    allow(ProfileApiClient).to receive(:create_school_student).and_return(created: [user_id])
  end

  def stub_profile_api_update_school_student
    allow(ProfileApiClient).to receive(:update_school_student)
  end

  def stub_profile_api_delete_school_student
    allow(ProfileApiClient).to receive(:delete_school_student)
  end

  def stub_profile_api_create_safeguarding_flag
    allow(ProfileApiClient).to receive(:create_safeguarding_flag)
  end
end
