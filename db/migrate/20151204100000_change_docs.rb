class ChangeDocs < ActiveRecord::Migration
  def change
    drop_table :docs
    create_table :docs do |t|
  	  t.string :name
  	  t.string :url
  	  t.string :uploadedby
  	  t.string :uploaddate
  	end
  end
end