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

    let(:params_empty_barcode) { ActionController::Parameters.new(
        'controller' => 'catalog',
        'action' => 'index',
        'barcode' => '') }

    let(:builder_with_barcode) { described_class.new(scope).with(params_with_barcode) }

    let(:builder_no_barcode) { described_class.new(scope).with(params) }

    let(:builder_empty_barcode) { described_class.new(scope).with(params_empty_barcode) }

    context 'when there is a barcode in params' do
      subject { builder_with_barcode.query }

      it 'filters for barcode when present in params' do
        expect(subject[:fq]).to include('barcode_ssim:123456')
      end
    end

    context 'when there is no barcode in params' do
      subject { builder_no_barcode.query }

      it 'does not filter for barcode when not in params' do
        expect(subject[:fq]).not_to include('barcode_ssim:')
      end
    end

    context 'when there is an empty barcode in params' do
      subject { builder_empty_barcode.query }

      it 'does not filter for barcode when not in params' do
        expect(subject[:fq]).not_to include('barcode_ssim:')
      end
    end
  end

  describe '.apply_filename_filter' do
    let(:params) { ActionController::Parameters.new(
        'controller' => 'catalog',
        'action' => 'index') }

    let(:params_with_filename) { ActionController::Parameters.new(
        'controller' => 'catalog',
        'action' => 'index',
        'filename' => 'test_file.xml') }

    let(:params_empty_filename) { ActionController::Parameters.new(
        'controller' => 'catalog',
        'action' => 'index',
        'filename' => '') }

    let(:builder_with_filename) { described_class.new(scope).with(params_with_filename) }

    let(:builder_no_filename) { described_class.new(scope).with(params) }

    let(:builder_empty_filename) { described_class.new(scope).with(params_empty_filename) }

    context 'when there is a filename in params' do
      subject { builder_with_filename.query }

      it 'filters for filename when present in params' do
        expect(subject[:fq]).to include("file_name_tesim:\"test_file.xml\"")
      end
    end

    context 'when there is no filename in params' do
      subject { builder_no_filename.query }

      it 'does not filter for filename when not in params' do
        expect(subject[:fq]).not_to include('file_name_tesim:')
      end
    end

    context 'when there is an empty filename in params' do
      subject { builder_empty_filename.query }

      it 'does not filter for filename when not in params' do
        expect(subject[:fq]).not_to include('file_name_tesim:')
      end
    end
  end

end
