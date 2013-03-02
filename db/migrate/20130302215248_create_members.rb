class CreateMembers < ActiveRecord::Migration
  def change
    create_table :members do |t|
      t.string :email
      t.string :login_token
      t.boolean :leader, :default => false
      t.references :location
      t.timestamps
    end
    add_index :members, :email
    add_index :members, :login_token
    add_index :members, :location_id
  end
end
