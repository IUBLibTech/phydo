class User < ActiveRecord::Base
  # Connects this user object to Hydra behaviors.
  include Hydra::User
  # Connects this user object to Role-management behaviors.
  include Hydra::RoleManagement::UserRoles
  load Rails.root.join('app', 'models', 'concerns', 'user_roles.rb')
  include Phydo::RoleManagement::UserRoles

  # Connects this user object to Hyrax behaviors.
  include Hyrax::User
  include Hyrax::UserUsageStats
  include LDAPGroupsLookup::Behavior

  def ldap_lookup_key
    uid || ''
  end

  if Blacklight::Utils.needs_attr_accessible?
    attr_accessible :email, :password, :password_confirmation
  end
  # Connects this user object to Blacklights Bookmarks.
  include Blacklight::User
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :rememberable, :trackable, :validatable,
         :omniauthable, :omniauth_providers => [:cas]

  # Method added by Blacklight; Blacklight uses #to_s on your
  # user class to get a user-displayable login/identifier for
  # the account.
  def to_s
    email
  end

  def self.find_for_iu_cas(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create! do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      user.email = [auth.uid, '@indiana.edu'].join
      user.password = Devise.friendly_token[0, 20]
    end
  end

  alias_method :original_groups, :groups

  # result not cached to allow for live addition of new roles
  def groups
    original_groups | mapped_groups | mapped_ldap_groups
  end

  def mapped_groups
    RoleMapper.fetch_groups(user: self)
  end

  def mapped_ldap_groups
    @mapped_ldap_groups ||= begin
      (RoleMapper.byname.keys & ldap_groups).inject([]) do |acc, lg|
        acc += (RoleMapper.byname[lg].dup || [])
      end
    end
  end
end
