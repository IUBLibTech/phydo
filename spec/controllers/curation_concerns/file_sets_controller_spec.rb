require 'rails_helper'

RSpec.describe Hyrax::FileSetsController do
  let(:file_set) { build(:file_set, user: user) }
  let(:user) { create(:user) }
  render_views

  describe "#show" do
    before do
      sign_in user
      file_set.save!
    end
    it "renders :show" do
      get :show, params: { id: file_set.id }
      expect(response).to render_template :show
    end
  end

  describe "#edit" do
    before do
      sign_in user
      file_set.save!
    end
    it "renders :edit" do
      get :edit, params: { id: file_set.id }
      expect(response).to render_template :edit
    end
  end
end
