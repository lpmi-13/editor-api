# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Listing class members', type: :request do
  before do
    authenticate_as_school_owner(school:)
    stub_user_info_api_for_teacher(teacher)
    stub_user_info_api_for_student(student)
  end

  let(:headers) { { Authorization: UserProfileMock::TOKEN } }
  let!(:class_member) { create(:class_member, student_id: student.id, school_class:) }
  let(:school_class) { build(:school_class, teacher_id: teacher.id, school:) }
  let(:school) { create(:school) }
  let(:student) { create(:student, school:) }
  let(:teacher) { create(:teacher, school:) }

  it 'responds 200 OK' do
    get("/api/schools/#{school.id}/classes/#{school_class.id}/members", headers:)
    expect(response).to have_http_status(:ok)
  end

  it 'responds with the class members JSON' do
    get("/api/schools/#{school.id}/classes/#{school_class.id}/members", headers:)
    data = JSON.parse(response.body, symbolize_names: true)

    expect(data.first[:student_id]).to eq(student.id)
  end

  it 'responds with the students JSON' do
    get("/api/schools/#{school.id}/classes/#{school_class.id}/members", headers:)
    data = JSON.parse(response.body, symbolize_names: true)

    expect(data.first[:student_name]).to eq('School Student')
  end

  # rubocop:disable RSpec/ExampleLength
  it "responds with nil attributes for students if the user profile doesn't exist" do
    student_id = SecureRandom.uuid
    stub_user_info_api_for_unknown_users(user_id: student_id)
    class_member.update!(student_id:)

    get("/api/schools/#{school.id}/classes/#{school_class.id}/members", headers:)
    data = JSON.parse(response.body, symbolize_names: true)

    expect(data.first[:student_name]).to be_nil
  end
  # rubocop:enable RSpec/ExampleLength

  # rubocop:disable RSpec/ExampleLength
  it 'does not include class members that belong to a different class' do
    student_id = SecureRandom.uuid
    stub_user_info_api_for_unknown_users(user_id: student_id)
    different_class = create(:school_class, school:, teacher_id: teacher.id)
    create(:class_member, school_class: different_class, student_id:)

    get("/api/schools/#{school.id}/classes/#{school_class.id}/members", headers:)
    data = JSON.parse(response.body, symbolize_names: true)

    expect(data.size).to eq(1)
  end
  # rubocop:enable RSpec/ExampleLength

  it 'responds 401 Unauthorized when no token is given' do
    get "/api/schools/#{school.id}/classes/#{school_class.id}/members"
    expect(response).to have_http_status(:unauthorized)
  end

  it 'responds 403 Forbidden when the user is a school-owner for a different school' do
    school = create(:school, id: SecureRandom.uuid)
    school_class.update!(school_id: school.id)

    get("/api/schools/#{school.id}/classes/#{school_class.id}/members", headers:)
    expect(response).to have_http_status(:forbidden)
  end

  it 'responds 403 Forbidden when the user is not the school-teacher for the class' do
    authenticate_as_school_teacher(school:)

    get("/api/schools/#{school.id}/classes/#{school_class.id}/members", headers:)
    expect(response).to have_http_status(:forbidden)
  end

  it 'responds 403 Forbidden when the user is a school-student' do
    authenticate_as_school_student(school:, student_id: SecureRandom.uuid)

    get("/api/schools/#{school.id}/classes/#{school_class.id}/members", headers:)
    expect(response).to have_http_status(:forbidden)
  end
end
