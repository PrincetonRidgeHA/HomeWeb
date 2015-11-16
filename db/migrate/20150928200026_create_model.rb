class CreateModel < ActiveRecord::Migration
  def change
    create_table :residents do |t|
  		t.string :name
  		t.string :addr
  		t.string :email
  		t.string :pnum
  	end
  	create_table :docs do |t|
  	  t.string :name
  	  t.string :url
  	  t.string :uploadedby
  	  t.string :securityring
  	end
  end
end
