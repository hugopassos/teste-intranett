class AddTeamIdToUsers < ActiveRecord::Migration[6.0]
  def change
    add_reference :users, :team, foreign_key: true, default: nil
  end
end
