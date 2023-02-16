# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GithubWebhooksController do

  around do |example|
    ClimateControl.modify GITHUB_WEBHOOK_SECRET: 'secret', GITHUB_WEBHOOK_REF: 'branches/whatever' do
      example.run
    end
  end

  describe 'github_push' do
    let(:params) {{
      ref: ref,
      commits: commits
    }}

    let(:headers) {
      {
        'X-Hub-Signature-256': "sha256=#{OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), ENV.fetch('GITHUB_WEBHOOK_SECRET'), params.to_json)}",
        'X-GitHub-Event': 'push',
        'Content-Type': 'application/json'
      }
    }

    before(:example) do
      allow(UploadJob).to receive(:perform_later)
      post '/github_webhooks', env: { 'RAW_POST_DATA': params.to_json }, headers: headers
    end

    context 'when webhook ref matches branch of interest' do
      let(:ref) { 'branches/whatever' }

      context 'when code has been added' do
        let(:commits) { [ { added: [], modified: [], removed: ['en/code/project1/main.py'] } ] }

        it 'schedules the upload job' do
          expect(UploadJob).to have_received(:perform_later)
        end
      end

      context 'when code has been modified' do
        let(:commits) { [ { added: [], modified: [ 'en/code/project1/main.py' ], removed: [] } ] }

        it 'schedules the upload job' do
          expect(UploadJob).to have_received(:perform_later)
        end
      end

      context 'when code has been removed' do
        let(:commits) { [ { added: [], modified: [], removed: ['en/code/project1/main.py'] } ] }

        it 'schedules the upload job' do
          expect(UploadJob).to have_received(:perform_later)
        end
      end

      context 'when code has not been changed' do
        let(:commits) { [ { added: ['en/step2.md'], modified: [ 'en/step1.md' ], removed: ['en/step0.md'] } ] }

        it 'does not schedule the upload job' do
          expect(UploadJob).not_to have_received(:perform_later)
        end
      end
    end

    context 'when webhook ref does not match branch of interest' do
      let(:ref) { 'branches/master' }
      let(:commits) { [ { added: [], modified: [ 'en/code/project1/main.py' ], removed: [] } ] }

      it 'does not schedule the upload job' do
        expect(UploadJob).not_to have_received(:perform_later)
      end
    end
  end
end
