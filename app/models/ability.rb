class Ability
  include Hydra::Ability
  include Hyrax::Ability
  self.ability_logic += [:everyone_can_create_curation_concerns,
                         :disable_content_blocks]

  # Do not show ContentBlock editors to anyone.
  # ContentBlocks will not be shown unless they already contain a value.
  def disable_content_blocks
    cannot :manage, ContentBlock
  end

  # Define any customized permissions here.
  def custom_permissions
    can [:file_status, :stage, :unstage], FileSet

    if current_user.ingest_from_external_sources?
    end

    if current_user.manage_users?
      can [:show, :add_user, :remove_user, :index], Role
    end

    if current_user.run_fixity_checks?
      can [:fixity], FileSet
    end
    # Limits deleting objects to a the admin user
    #
    # if current_user.admin?
    #   can [:destroy], ActiveFedora::Base
    # end

    # Limits creating new objects to a specific group
    #
    # if user_groups.include? 'special_group'
    #   can [:create], ActiveFedora::Base
    # end
  end
end
