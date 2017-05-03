require 'rails_helper'

describe 'Sanity check for the root URL' do
  before { visit '/' }
  it 'has home page content' do
    expect(body).to have_text /Search Phydo/
  end
end
