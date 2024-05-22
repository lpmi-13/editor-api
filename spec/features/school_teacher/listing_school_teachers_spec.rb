# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Listing school teachers', type: :request do
  before do
    authenticate_as_school_owner(school_id: school.id)
    stub_profile_api_list_school_teachers(user_id: teacher_id)
    stub_user_info_api_for_teacher(teacher_id:, school_id: School::ID)
  end

  let(:headers) { { Authorization: UserProfileMock::TOKEN } }
  let(:school) { create(:school, id: School::ID) }
  let(:teacher_id) { User::TEACHER_ID }

  it 'responds 200 OK' do
    get("/api/schools/#{school.id}/teachers", headers:)
    expect(response).to have_http_status(:ok)
  end

  it 'responds 200 OK when the user is a school-teacher' do
    authenticate_as_school_teacher(school_id: school.id)

    get("/api/schools/#{school.id}/teachers", headers:)
    expect(response).to have_http_status(:ok)
  end

  it 'responds with the school teachers JSON' do
    get("/api/schools/#{school.id}/teachers", headers:)
    data = JSON.parse(response.body, symbolize_names: true)

    expect(data.first[:name]).to eq('School Teacher')
  end

  it 'responds 401 Unauthorized when no token is given' do
    get "/api/schools/#{school.id}/teachers"
    expect(response).to have_http_status(:unauthorized)
  end

  it 'responds 403 Forbidden when the user is a school-owner for a different school' do
    school.update!(id: SecureRandom.uuid)

    get("/api/schools/#{school.id}/teachers", headers:)
    expect(response).to have_http_status(:forbidden)
  end

  it 'responds 403 Forbidden when the user is a school-student' do
    authenticate_as_school_student

    get("/api/schools/#{school.id}/teachers", headers:)
    expect(response).to have_http_status(:forbidden)
  end
end
