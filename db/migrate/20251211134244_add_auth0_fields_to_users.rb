class AddAuth0FieldsToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :provider, :string
    add_column :users, :uid, :string
    add_column :users, :name, :string
    add_column :users, :image, :string
    
    #Added index for faster lookups
    add_index :users, [:provider, :uid], unique: true
    
    #Email optional
    change_column :users, :email, :string, null: true
  end
end
