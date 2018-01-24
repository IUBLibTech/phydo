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

  shared_examples 'apply_filter examples' do |blacklight_param, blacklight_value, solr_param, solr_value|
    let(:params) { ActionController::Parameters.new(
        'controller' => 'catalog',
        'action' => 'index') }
    let(:params_with_value) { ActionController::Parameters.new(
        'controller' => 'catalog',
        'action' => 'index',
        blacklight_param => blacklight_value) }

    let(:params_empty_value) { ActionController::Parameters.new(
        'controller' => 'catalog',
        'action' => 'index',
        blacklight_param => '') }

    let(:builder_with_value) { described_class.new(scope).with(params_with_value) }

    let(:builder_no_value) { described_class.new(scope).with(params) }

    let(:builder_empty_value) { described_class.new(scope).with(params_empty_value) }

    context 'when there is a value in params' do
      subject { builder_with_value.query }

      it 'filters for value when present in params' do
        expect(subject[:fq]).to include(solr_param + ':' + solr_value)
      end
    end

    context 'when there is no value in params' do
      subject { builder_no_value.query }

      it 'does not filter for value when not in params' do
        expect(subject[:fq]).not_to include(solr_param)
      end
    end

    context 'when there is an empty value in params' do
      subject { builder_empty_value.query }

      it 'does not filter for value when not in params' do
        expect(subject[:fq]).not_to include(solr_param)
      end
    end
  end

  describe '.apply_barcode_filter' do
    include_examples 'apply_filter examples', 'barcode', '123456', 'barcode_ssim', '123456'
  end

  describe '.apply_filename_filter' do
    include_examples 'apply_filter examples', 'filename', 'test_file.xml', 'file_name_tesim', '"test_file.xml"'
  end

  describe '.apply_file_path_segment_filter' do
    include_examples 'apply_filter examples', 'file_path_segment', '/test/path', 'file_path_tesim', '"/test/path"'
  end
end
