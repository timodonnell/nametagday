class CreateAdmins < ActiveRecord::Migration
  def change
    create_table :admins do |t|
      t.string :first_name, :last_name, :email, :hashed_password, :remember_token, :password_token
      t.boolean :enabled
      t.datetime :remember_token_expires_at
      t.timestamps
    end
  end
end
