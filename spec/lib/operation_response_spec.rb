# frozen_string_literal: true

require 'spec_helper'
require_relative '../../lib/operation_response'

RSpec.describe OperationResponse do
  describe '#success?' do
    context 'when :error not present' do
      it 'returns true' do
        response = described_class.new
        expect(response.success?).to eq(true)
      end
    end

    context 'when :error has been set' do
      it 'returns false' do
        response = described_class.new
        response[:error] = 'An error'
        expect(response.success?).to eq(false)
      end
    end
  end

  describe '#failure?' do
    context 'when :error not present' do
      it 'returns false' do
        response = described_class.new
        expect(response.failure?).to eq(false)
      end
    end

    context 'when :error has been set' do
      it 'returns true' do
        response = described_class.new
        response[:error] = 'An error'
        expect(response.failure?).to eq(true)
      end
    end
  end
end