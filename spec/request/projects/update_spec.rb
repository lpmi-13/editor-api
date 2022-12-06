# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Project update requests', type: :request do
  let(:headers) { { Authorization: 'dummy-token' } }

  context 'when authed user is project creator' do
    let(:project) { create(:project, :with_default_component) }
    let!(:component) { create(:component, project:) }
    let(:default_component_params) do
      project.components.first.attributes.symbolize_keys.slice(
        :id,
        :name,
        :content,
        :extension,
        :index
      )
    end

    let(:params) do
      { project:
        { components: [
          default_component_params,
          { id: component.id, name: 'updated', extension: 'py', content: 'updated component content' }
        ] } }
    end

    before do
      mock_oauth_user(project.user_id)
    end

    it 'returns success response' do
      put "/api/projects/#{project.identifier}", params: params, headers: headers
      expect(response).to have_http_status(:ok)
    end

    it 'returns updated project json' do
      put "/api/projects/#{project.identifier}", params: params, headers: headers
      expect(response.body).to include('updated component content')
    end

    it 'calls update operation' do
      mock_response = instance_double(OperationResponse)
      allow(mock_response).to receive(:success?).and_return(true)
      allow(Project::Update).to receive(:call).and_return(mock_response)
      put "/api/projects/#{project.identifier}", params: params, headers: headers
      expect(Project::Update).to have_received(:call)
    end

    context 'when update is invalid' do
      let(:params) { { project: { components: [] } } }

      it 'returns error response' do
        put "/api/projects/#{project.identifier}", params: params, headers: headers
        expect(response).to have_http_status(:bad_request)
      end
    end
  end

  context 'when authed user is not creator' do
    let(:project) { create(:project) }
    let(:params) { { project: { components: [] } } }

    before do
      mock_oauth_user
    end

    it 'returns forbidden response' do
      put "/api/projects/#{project.identifier}", params: params, headers: headers
      expect(response).to have_http_status(:forbidden)
    end
  end

  context 'when auth token is invalid' do
    let(:project) { create(:project) }

    before do
      allow(HydraAdminApi).to receive(:fetch_oauth_user_id).and_return(nil)
    end

    it 'returns unauthorized' do
      put "/api/projects/#{project.identifier}", headers: headers

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
