module Phydo
  module RoleManagement
    module UserRoles
      def collection_manager?
        roles.where(name: 'collection_manager').any?
      end
    end
  end
end
