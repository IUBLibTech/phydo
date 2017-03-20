require 'rails_helper'

describe 'FileSet details view' do
  context 'when the FileSet has associated Preservation Events' do
    let(:user) { FactoryGirl.create(:user) }
    let(:file_set) { FactoryGirl.create(:file_set, user: user) }
    let(:event) { FactoryGirl.create(:preservation_event, premis_event_related_object: file_set) }
    # TODO: This URL comes from routes defined within the `preservation` gem.
    # The proper way to get these is to use the URL helpers from the
    # preservation gem.
    let(:event_url) { "preservation/events/#{event.id}" }

    before do
      login_as(user)
      file_set.save!
      event.save!
    end

    it 'displays a list of links to each Preservation Event details page' do
      visit url_for(file_set)
      expect(page).to have_link(event.premis_event_type_label, event_url)
    end
  end
end
