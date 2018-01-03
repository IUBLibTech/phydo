require 'rails_helper'

RSpec.describe IngestYAMLJob do
  describe 'ingesting a yaml file', clean_fedora: true do
    let(:user) { User.first_or_create!(email: 'test@example.com', password: 'password') }
    let(:yaml_file) { '' }
    let(:resource1) { Work.new id: 'resource1' }
    before do
      allow(Work).to receive(:new).and_return(resource1)
    end

    it 'succeeds' do
      yaml_file = Rails.root.join('spec', 'fixtures', 'iu_ingest', 'test_2_parts.yaml').to_s
      described_class.perform_now(yaml_file, user)
      resource1.reload
      expect(resource1.title).to eq ['Test with 2 Parts']
      expect(resource1.file_sets.count).to eq 4
      expect(resource1.file_sets.first.mime_type).to match /external-body/
    end
  end
end
