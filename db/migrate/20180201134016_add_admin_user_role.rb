class AddAdminUserRole < ActiveRecord::Migration[5.1]
  def up
    if Role.where(name: 'admin').none?
      Role.create(name: 'admin')
      puts 'Created admin Role.'
    else
      puts 'Admin role already exists.'
    end
  end
  def down
    puts 'No action on rollback.'
  end
end
