# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Listing school students', type: :request do
  before do
    authenticate_as_school_owner(owner)
    stub_profile_api_list_school_students(user_id: student.id)
    stub_user_info_api_for(student)
  end

  let(:headers) { { Authorization: UserProfileMock::TOKEN } }
  let(:school) { create(:school) }
  let(:student) { create(:student, school:, name: 'School Student') }
  let(:owner) { create(:owner, school:) }

  it 'responds 200 OK' do
    get("/api/schools/#{school.id}/students", headers:)
    expect(response).to have_http_status(:ok)
  end

  it 'responds 200 OK when the user is a school-teacher' do
    teacher = create(:teacher, school:)
    authenticate_as_school_teacher(teacher)

    get("/api/schools/#{school.id}/students", headers:)
    expect(response).to have_http_status(:ok)
  end

  it 'responds with the school students JSON' do
    get("/api/schools/#{school.id}/students", headers:)
    data = JSON.parse(response.body, symbolize_names: true)

    expect(data.first[:name]).to eq('School Student')
  end

  it 'responds 401 Unauthorized when no token is given' do
    get "/api/schools/#{school.id}/students"
    expect(response).to have_http_status(:unauthorized)
  end

  it 'responds 403 Forbidden when the user is a school-owner for a different school' do
    Role.student.find_by(user_id: student.id, school:).delete
    Role.owner.find_by(user_id: owner.id, school:).delete
    school.update!(id: SecureRandom.uuid)

    get("/api/schools/#{school.id}/students", headers:)
    expect(response).to have_http_status(:forbidden)
  end

  it 'responds 403 Forbidden when the user is a school-student' do
    student = create(:student, school:)
    authenticated_in_hydra_as(student)

    get("/api/schools/#{school.id}/students", headers:)
    expect(response).to have_http_status(:forbidden)
  end
end
