require 'rails_helper'
require './lib/hydradam/preingest/IU/tarball'
require './lib/hydradam/preingest/IU/yaml'

RSpec.describe PreingestJob do
  let(:document_class) { nil }
  let(:preingest_file) { '' }
  let(:user) { User.first_or_create!(email: 'test@example.com', password: 'password') }
  let(:yaml_file) { '' }
  shared_examples "successfully preingests" do
    it "writes the expected yaml output" do
      yaml_content = File.open(yaml_file) { |f| Psych.load(f) }
      expect(File).to receive(:write).with(yaml_file, yaml_content.to_yaml)
      described_class.perform_now(document_class, preingest_file, user)
    end
  end

  context "for IU YAML" do
    let(:document_class) { HydraDAM::Preingest::IU::Yaml }
    let(:preingest_file) { Rails.root.join("spec", "fixtures", "IU", "sip.yml").to_s }
    let(:yaml_file) { preingest_file }
    include_examples "successfully preingests"
  end

  context "for an IU tarball" do
    let(:document_class) { HydraDAM::Preingest::IU::Tarball }
    let(:preingest_file) { Rails.root.join("spec", "fixtures", "IU", "sip.tar").to_s }
    let(:yaml_file) { preingest_file.sub(/\.tar$/, '.yml') }
    # include_examples "successfully preingests"
  end
end
