# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Showing a lesson', type: :request do
  before do
    authenticate_as_school_owner(owner_id:, school_id: school.id)
    stub_user_info_api_for_teacher(teacher_id:, school_id: school.id)
  end

  let!(:lesson) { create(:lesson, name: 'Test Lesson', visibility: 'public', user_id: teacher_id) }
  let(:headers) { { Authorization: UserProfileMock::TOKEN } }
  let(:teacher_id) { SecureRandom.uuid }
  let(:owner_id) { SecureRandom.uuid }
  let(:school) { create(:school) }

  it 'responds 200 OK' do
    get("/api/lessons/#{lesson.id}", headers:)
    expect(response).to have_http_status(:ok)
  end

  it 'responds 200 OK when no token is given' do
    get "/api/lessons/#{lesson.id}"
    expect(response).to have_http_status(:ok)
  end

  it 'responds with the lesson JSON' do
    get("/api/lessons/#{lesson.id}", headers:)
    data = JSON.parse(response.body, symbolize_names: true)

    expect(data[:name]).to eq('Test Lesson')
  end

  it 'responds with the user JSON' do
    get("/api/lessons/#{lesson.id}", headers:)
    data = JSON.parse(response.body, symbolize_names: true)

    expect(data[:user_name]).to eq('School Teacher')
  end

  # rubocop:disable RSpec/ExampleLength
  it "responds with nil attributes for the user if their user profile doesn't exist" do
    user_id = SecureRandom.uuid
    stub_user_info_api_for_unknown_users(user_id:)
    lesson.update!(user_id:)

    get("/api/lessons/#{lesson.id}", headers:)
    data = JSON.parse(response.body, symbolize_names: true)

    expect(data[:user_name]).to be_nil
  end
  # rubocop:enable RSpec/ExampleLength

  it 'responds 404 Not Found when no lesson exists' do
    get('/api/lessons/not-a-real-id', headers:)
    expect(response).to have_http_status(:not_found)
  end

  context "when the lesson's visibility is 'private'" do
    let!(:lesson) { create(:lesson, name: 'Test Lesson', visibility: 'private') }
    let(:owner_id) { SecureRandom.uuid }

    it 'responds 200 OK when the user owns the lesson' do
      stub_user_info_api_for_owner(owner_id:, school_id: school.id)
      lesson.update!(user_id: owner_id)

      get("/api/lessons/#{lesson.id}", headers:)
      expect(response).to have_http_status(:ok)
    end

    it 'responds 403 Forbidden when the user does not own the lesson' do
      get("/api/lessons/#{lesson.id}", headers:)
      expect(response).to have_http_status(:forbidden)
    end
  end

  context "when the lesson's visibility is 'teachers'" do
    let(:school) { create(:school) }
    let!(:lesson) { create(:lesson, school:, name: 'Test Lesson', visibility: 'teachers', user_id: teacher_id) }
    let(:owner_id) { SecureRandom.uuid }

    it 'responds 200 OK when the user owns the lesson' do
      stub_user_info_api_for_owner(owner_id:, school_id: school.id)
      lesson.update!(user_id: owner_id)

      get("/api/lessons/#{lesson.id}", headers:)
      expect(response).to have_http_status(:ok)
    end

    it 'responds 200 OK when the user is a school-owner or school-teacher within the school' do
      get("/api/lessons/#{lesson.id}", headers:)
      expect(response).to have_http_status(:ok)
    end

    it 'responds 403 Forbidden when the user is a school-owner for a different school' do
      school = create(:school, id: SecureRandom.uuid)
      lesson.update!(school_id: school.id)

      get("/api/lessons/#{lesson.id}", headers:)
      expect(response).to have_http_status(:forbidden)
    end

    it 'responds 403 Forbidden when the user is a school-student' do
      authenticate_as_school_student

      get("/api/lessons/#{lesson.id}", headers:)
      expect(response).to have_http_status(:forbidden)
    end
  end

  context "when the lesson's visibility is 'students'" do
    let(:school) { create(:school) }
    let(:school_class) { create(:school_class, teacher_id:, school:) }
    let!(:lesson) { create(:lesson, school_class:, name: 'Test Lesson', visibility: 'students', user_id: teacher_id) }
    let(:teacher_id) { SecureRandom.uuid }

    it 'responds 200 OK when the user owns the lesson' do
      authenticate_as_school_teacher(school_id: school.id)
      lesson.update!(user_id: teacher_id)

      get("/api/lessons/#{lesson.id}", headers:)
      expect(response).to have_http_status(:ok)
    end

    # rubocop:disable RSpec/ExampleLength
    it "responds 200 OK when the user is a school-student within the lesson's class" do
      student_id = SecureRandom.uuid
      authenticate_as_school_student(student_id:, school_id: school.id)
      stub_user_info_api_for_student(student_id:, school_id: school.id)
      create(:class_member, school_class:, student_id:)

      get("/api/lessons/#{lesson.id}", headers:)
      expect(response).to have_http_status(:ok)
    end
    # rubocop:enable RSpec/ExampleLength

    it "responds 403 Forbidden when the user is a school-student but isn't within the lesson's class" do
      authenticate_as_school_student

      get("/api/lessons/#{lesson.id}", headers:)
      expect(response).to have_http_status(:forbidden)
    end

    it 'responds 403 Forbidden when the user is a school-owner for a different school' do
      school = create(:school, id: SecureRandom.uuid)
      lesson.update!(school_id: school.id)

      get("/api/lessons/#{lesson.id}", headers:)
      expect(response).to have_http_status(:forbidden)
    end
  end
end
