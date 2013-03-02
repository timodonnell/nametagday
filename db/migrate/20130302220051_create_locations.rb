class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.string :name
      t.string :address
      t.string :suite
      t.string :city
      t.string :state
      t.string :zip
      t.string :country
      t.decimal  "lat", :precision => 15, :scale => 10
      t.decimal  "lng", :precision => 15, :scale => 10
      t.timestamps
    end
  end
end
