require 'rails_helper'

RSpec.describe IngestYAMLJob do
  describe "ingesting a yaml file" do
    let(:user) { User.first_or_create!(email: 'test@example.com', password: 'password') }
    let(:yaml_file) { '' }
    let(:fileset) { FileSet.new }
    let(:resource1) { Work.new id: 'resource1' }
    let(:path) { Rails.root.join("spec", "fixtures", "IU", "test.wav") }
    let(:file_hash) { { path: path, mime_type: 'FIXME' } }
    let(:file) { described_class.new.send(:decorated_file, file_hash) }
    let(:actor1) { double('actor1') }
    before do
      allow(CurationConcerns::Actors::FileSetActor).to receive(:new).and_return(actor1)
      allow(FileSet).to receive(:new).and_return(fileset)
      allow(Work).to receive(:new).and_return(resource1)
      allow(fileset).to receive(:id).and_return('file1')
      allow(fileset).to receive(:title=)
      allow_any_instance_of(described_class).to receive(:decorated_file).and_return(file)
      allow_any_instance_of(described_class).to receive(:add_ingestion_event)
      allow_any_instance_of(Work).to receive(:save!)
    end
    shared_examples "successfully ingests" do
      it "ingests some stuff" do
        allow(actor1).to receive(:attach_related_object).with(resource1)
        allow(actor1).to receive(:attach_content).with(instance_of(File))
        allow(actor1).to receive(:create_metadata).with(resource1, {})
        allow(actor1).to receive(:create_content).with(file, 'intermediate_file')
        described_class.perform_now(yaml_file, user)
        expect(resource1.title).to eq(['Test title'])
      end
    end
  
    context "for test.yml" do
      let(:yaml_file) { Rails.root.join("spec", "fixtures", "IU", "test.yml").to_s }
      include_examples "successfully ingests"
      pending "successfully adds multiples files to the same FileSet"
      pending "stores remote redirects for purls"
      pending "creates a Work, or doesn't"
    end
  end
end
