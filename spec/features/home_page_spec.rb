require 'rails_helper'

describe 'Sanity check for the root URL' do
  before { visit '/' }
  it 'has home page content' do
    expect(body).to have_text /Search Phydo/
  end
end

describe 'Homepage as admin' do
  let(:user) { build :admin }

  before do
    login_as user
    visit '/'
  end

  it 'does not show ContentBlocks' do
    expect(body).not_to have_selector(:css, 'div.content_block_preview')
  end
end
