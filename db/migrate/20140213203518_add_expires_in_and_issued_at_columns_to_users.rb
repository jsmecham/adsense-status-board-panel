class AddExpiresInAndIssuedAtColumnsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :access_token_expires_in, :integer
    add_column :users, :access_token_issued_at, :datetime
  end
end
