class CreateModel < ActiveRecord::Migration
  def up
  	create_table :residents do |t|
  		t.string :name
  		t.string :addr
  		t.string :email
  		t.string :pnum
  		
  	end
  end

  def down
  	drop_table :residents
  end
end
