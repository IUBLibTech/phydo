# Generated via
#  `rails generate curation_concerns:work Work`
require 'rails_helper'
require 'capybara'
include Warden::Test::Helpers

feature 'Create a Work' do
  context 'a logged in user' do
    let(:user_attributes) do
      { email: 'test@example.com' }
    end
    let(:user) do
      User.new(user_attributes) { |u| u.save(validate: false) }
    end

    before do
      # NOTE: this is the same result as running `rake hyrax:default_admin_set`
      AdminSet.find_or_create_default_admin_set_id
      login_as user
    end

    scenario 'the work is created', clean_fedora: true do
      visit new_hyrax_work_path
      fill_in 'Title', with: 'Test Work'
      click_button 'Save'
      expect(page).to have_content 'Test Work'
    end
  end
end
