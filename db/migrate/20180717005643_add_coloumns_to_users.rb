class AddColoumnsToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :provider,           :string
    add_column :users, :nickname,           :string
    add_column :users, :uid,                :string
    add_column :users, :profile_image_path, :string
  end
end
