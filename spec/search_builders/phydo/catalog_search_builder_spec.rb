require 'rails_helper'
require_relative '../../../app/search_builders/phydo/catalog_search_builder'

RSpec.describe Phydo::CatalogSearchBuilder do
  let(:me) { create(:user) }

  let(:config) { CatalogController.blacklight_config }

  let(:scope) do
    double('The scope',
           blacklight_config: config,
           current_ability: Ability.new(me),
           current_user: me)
  end

  describe '.apply_barcode_filter' do
    let(:params) { ActionController::Parameters.new(
        'controller' => 'catalog',
        'action' => 'index') }

    let(:params_with_barcode) { ActionController::Parameters.new(
        'controller' => 'catalog',
        'action' => 'index',
        'barcode' => '123456') }

    let(:builder_with_barcode) { described_class.new(scope).with(params_with_barcode) }

    let(:builder_no_barcode) { described_class.new(scope).with(params) }

    context 'when there is a barcode in params' do
      subject { builder_with_barcode.query }

      it 'filters for barcode when present in params' do
        expect(subject[:fq]).to include('barcode_ssim:123456')
      end
    end

    context 'when there is no barcode in params' do
      subject { builder_no_barcode.query }

      it 'does not filter for barcode when not in params' do
        expect(subject[:fq]).not_to include('barcode_ssim:123456')
      end
    end
  end
end
