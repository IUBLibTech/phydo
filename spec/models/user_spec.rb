require 'rails_helper'

describe User do
  describe '#to_s' do
    it 'returns email' do
      expect(subject.to_s).to eq subject.email
    end
  end
  describe '.find_for_iu_cas' do
    let(:auth) { double() }
    before(:each) do
      allow(auth).to receive(:provider) { 'mocked_provider' }
      allow(auth).to receive(:uid) { 'mocked_uid' }
    end
    context 'without an existing user' do
      it 'creates the user' do
        expect { described_class.find_for_iu_cas(auth) }.to change(User, :count).by(1)
      end
    end
    context 'with an existing user' do
      let!(:user) { User.create!(provider: auth.provider, uid: auth.uid, email: 'test@example.com', password: 'password') }
      it 'finds and uses the existing user' do
        expect { described_class.find_for_iu_cas(auth) }.not_to change(User, :count)
        expect(described_class.find_for_iu_cas(auth)).to eq user
      end
    end
  end
end  
