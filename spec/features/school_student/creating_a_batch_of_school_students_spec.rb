# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Creating a batch of school students', type: :request do
  before do
    authenticated_in_hydra_as(owner)
    stub_profile_api_create_school_student
    stub_profile_api_create_safeguarding_flag
  end

  let(:headers) { { Authorization: UserProfileMock::TOKEN } }
  let(:school) { create(:verified_school) }
  let(:student_id) { SecureRandom.uuid }
  let(:owner) { create(:owner, school:) }

  let(:file) { fixture_file_upload('students.csv') }

  it 'creates the school owner safeguarding flag' do
    post("/api/schools/#{school.id}/students/batch", headers:, params: { file: })
    expect(ProfileApiClient).to have_received(:create_safeguarding_flag).with(token: UserProfileMock::TOKEN, flag: ProfileApiClient::SAFEGUARDING_FLAGS[:owner])
  end

  it 'does not create the school teacher safeguarding flag' do
    post("/api/schools/#{school.id}/students/batch", headers:, params: { file: })
    expect(ProfileApiClient).not_to have_received(:create_safeguarding_flag).with(token: UserProfileMock::TOKEN, flag: ProfileApiClient::SAFEGUARDING_FLAGS[:teacher])
  end

  it 'responds 204 No Content' do
    post("/api/schools/#{school.id}/students/batch", headers:, params: { file: })
    expect(response).to have_http_status(:no_content)
  end

  it 'responds 204 No Content when the user is a school-teacher' do
    teacher = create(:teacher, school:)
    authenticated_in_hydra_as(teacher)

    post("/api/schools/#{school.id}/students/batch", headers:, params: { file: })
    expect(response).to have_http_status(:no_content)
  end

  it 'does not create the school owner safeguarding flag when the user is a school-teacher' do
    teacher = create(:teacher, school:)
    authenticated_in_hydra_as(teacher)

    post("/api/schools/#{school.id}/students/batch", headers:, params: { file: })
    expect(ProfileApiClient).not_to have_received(:create_safeguarding_flag).with(token: UserProfileMock::TOKEN, flag: ProfileApiClient::SAFEGUARDING_FLAGS[:owner])
  end

  it 'creates the school teacher safeguarding flag when the user is a school-teacher' do
    teacher = create(:teacher, school:)
    authenticated_in_hydra_as(teacher)

    post("/api/schools/#{school.id}/students/batch", headers:, params: { file: })
    expect(ProfileApiClient).to have_received(:create_safeguarding_flag).with(token: UserProfileMock::TOKEN, flag: ProfileApiClient::SAFEGUARDING_FLAGS[:teacher])
  end

  it 'responds 422 Unprocessable Entity when params are invalid' do
    post("/api/schools/#{school.id}/students/batch", headers:, params: {})
    expect(response).to have_http_status(:unprocessable_entity)
  end

  it 'responds 401 Unauthorized when no token is given' do
    post("/api/schools/#{school.id}/students/batch", params: { file: })
    expect(response).to have_http_status(:unauthorized)
  end

  it 'responds 403 Forbidden when the user is a school-owner for a different school' do
    Role.owner.find_by(user_id: owner.id, school:).delete
    school.update!(id: SecureRandom.uuid)

    post("/api/schools/#{school.id}/students/batch", headers:, params: { file: })
    expect(response).to have_http_status(:forbidden)
  end

  it 'responds 403 Forbidden when the user is a school-student' do
    student = create(:student, school:)
    authenticated_in_hydra_as(student)

    post("/api/schools/#{school.id}/students/batch", headers:, params: { file: })
    expect(response).to have_http_status(:forbidden)
  end
end
