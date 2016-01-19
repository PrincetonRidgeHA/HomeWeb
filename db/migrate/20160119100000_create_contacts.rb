class CreateContacts < ActiveRecord::Migration
  def up
    create_table :contacts do |t|
  	  t.string :title
  	  t.string :name
  	  t.string :email
  	end
  end
  def down
    drop_table :contacts
  end
end