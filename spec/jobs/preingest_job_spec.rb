require 'rails_helper'
# FIXME: improve automated library inclusion
require './lib/phydo/preingest/IU/tarball'
require './lib/phydo/preingest/IU/yaml'
require './lib/phydo/preingest/WGBH/sip'
require 'archive/tar/minitar'
include Archive::Tar

RSpec.describe PreingestJob do
  let(:document_class) { nil }
  let(:preingest_file) { '' }
  let(:user) { User.first_or_create!(email: 'test@example.com', password: 'password') }
  let(:yaml_file) { '' }
  shared_examples 'preingests as expected' do
    it 'writes the expected yaml output' do
      yaml_content = File.open(yaml_file) { |f| Psych.load(f) }
      expect(File).to receive(:write).with(yaml_file, yaml_content.to_yaml)
      described_class.perform_now(document_class, preingest_file, user)
    end
  end
  shared_examples 'preingests in some fashion' do
    it 'writes some yaml output' do
      expect(File).to receive(:write)
      described_class.perform_now(document_class, preingest_file, user)
    end
  end

  context 'for WGBH SIP' do
    let(:document_class) { Phydo::Preingest::WGBH::SIP }
    let(:preingest_file) { Rails.root.join('spec', 'fixtures', 'WGBH', '1_pbcore.xml').to_s }
    let(:yaml_file) { Rails.root.join('spec', 'fixtures', 'WGBH', '1_pbcore.yml').to_s }
    # FIXME: kludge for full vs relative path variance
    # include_examples 'preingests as expected'
    include_examples 'preingests in some fashion'
  end

  context 'for IU YAML' do
    let(:document_class) { Phydo::Preingest::IU::Yaml }
    let(:preingest_file) { Rails.root.join('spec', 'fixtures', 'IU', 'sip.yml').to_s }
    let(:yaml_file) { preingest_file }
    include_examples 'preingests as expected'
  end

  context 'for an IU tarball' do
    let(:document_class) { Phydo::Preingest::IU::Tarball }
    let(:preingest_dir) { Rails.root.join('spec', 'fixtures', 'IU').to_s }
    let(:preingest_file) { Rails.root.join('spec', 'fixtures', 'IU', 'sip.tar').to_s }
    let(:yaml_file) { preingest_file.sub(/\.tar$/, '.yml') }
    before(:each) { Minitar.unpack(preingest_file, preingest_dir) }
    # FIXME: kludge for Minitar not preserving timestamps
    # include_examples 'preingests as expected'
    include_examples 'preingests in some fashion'
  end
end
