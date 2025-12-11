class AddAuth0AuthenticationToUsers < ActiveRecord::Migration[7.0]
  def change
    #Adding Auth0 to users table
    add_column :users, :provider, :string
    add_column :users, :uid, :string
    
    #Unique index to prevent duplicate auth0 accounts
    add_index :users, [:provider, :uid], unique: true
    
    # Make email null for auth0
    change_column_null :users, :email, true
    
    # Set defaults for existing columns to handle Auth0 data
    change_column_default :users, :first_name, from: nil, to: "User"
  end
end