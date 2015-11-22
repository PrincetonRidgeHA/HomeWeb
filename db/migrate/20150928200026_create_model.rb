class CreateModel < ActiveRecord::Migration
  def up
    create_table :docs do |t|
  	  t.string :name
  	  t.string :url
  	  t.string :uploadedby
  	  t.string :uploaddate
  	  t.string :securityring
  	end
    create_table :residents do |t|
  		t.string :name
  		t.string :addr
  		t.string :email
  		t.string :pnum
  	end
  	create_table :yardwinners do |t|
  	  t.integer :year
  	  t.integer :month
  	  t.string :name
  	  t.string :address
  	  t.string :imgpath
  	end
  end
  def down
    drop_table :docs
    drop_table :residents
    drop_table :yom
  end
end
