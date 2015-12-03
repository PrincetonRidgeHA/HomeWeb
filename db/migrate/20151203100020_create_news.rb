class CreateNews < ActiveRecord::Migration
  def up
    create_table :news do |t|
  	  t.string :title
  	  t.text :content
  	  t.string :uploadedby
  	  t.string :uploaddate
  	end
  end
  def down
    drop_table :news
  end
end