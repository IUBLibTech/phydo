module Phydo
  module RoleManagement
    module UserRoles
      def ingest_from_external_sources?
        admin? || roles.where(name: 'ingest_from_external_sources').any?
      end
      def manage_roles?
        admin? || roles.where(name: 'manage_roles').any?
      end
      def manage_users?
        admin? || roles.where(name: 'manage_users').any?
      end
      def run_fixity_checks?
        admin? || roles.where(name: 'run_fixity_checks').any?
      end
    end
  end
end
