class AddAdminUserRole < ActiveRecord::Migration[5.1]
  def up
    [:admin, :ingest_from_external_sources, :manage_users, :run_fixity_checks].each do |role|
      if Role.where(name: role.to_s).none?
        Role.create(name: role.to_s)
        puts "Created role: #{role}."
      else
        puts "Role already exists: #{role}."
      end
    end
  end
  def down
    puts 'No action on rollback.'
  end
end
