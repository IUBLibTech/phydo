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
  describe 'has groups methods' do
    let(:test_mapping) do
      mapping_hash = Hash.new{ |h, k| h[k] = [] }
      mapping_hash['ldap1'] = ['ldap1_mapped_1', 'ldap1_mapped_2']
      mapping_hash['local_key'] = ['local1_mapped_1', 'local1_mapped_2']
      mapping_hash
    end
    before do
      allow(subject).to receive(:user_key).and_return('local_key')
      allow(RoleMapper).to receive(:byname).and_return(test_mapping)
    end
    describe '#groups' do
      it 'returns the Array union of group methods' do
        expect(subject.groups).to eq subject.original_groups | subject.mapped_groups | subject.ldap_groups
      end
    end
    describe '#mapped_ldap_groups' do
      before do
        allow(subject).to receive(:ldap_groups).and_return(['ldap1', 'ldap2'])
      end
      it 'returns mapped values' do
        expect(subject.mapped_ldap_groups).to eq test_mapping['ldap1']
      end
    end
    describe '#mapped_groups' do
      it 'returns mapped values' do
        expect(subject.mapped_groups).to eq test_mapping['local_key']
      end
    end
    describe '#original_groups' do
      Struct.new('Role', :name)
      let(:role_names) { ['role1', 'role2'] }
      let(:roles) do
        role_names.map { |r| Struct::Role.new(r) }
      end

      before do
        allow(subject).to receive(:roles).and_return(roles)
      end

      context 'when user is a guest' do
        before do
          allow(subject).to receive(:guest?).and_return(true)
        end
        it 'returns role names' do
          expect(subject.original_groups).to eq role_names
        end
      end
      context 'when user is a new_record' do
        before do
          allow(subject).to receive(:new_record?).and_return(true)
        end
        it 'returns role names' do
          expect(subject.original_groups).to eq role_names
        end
      end
      context 'when user is neither new_record nor guest' do
        before do
          allow(subject).to receive(:guest?).and_return(false)
          allow(subject).to receive(:new_record?).and_return(false)
        end
        it 'returns role names, plus registered' do
          expect(subject.original_groups).to eq role_names + ['registered']
        end
      end
    end
  end
end
