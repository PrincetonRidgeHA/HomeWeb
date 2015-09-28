class CreateModel < ActiveRecord::Migration
  def up
  	create_table :residents do |t|
  		t.string :lname
  		t.string :addr
  	end
  end

  def down
  	drop_table :residents
  end
end
