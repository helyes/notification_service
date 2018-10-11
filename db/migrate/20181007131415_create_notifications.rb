class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.string :summary,     limit: 160
      t.string :description, limit: 2048
      t.timestamps null: false
    end
    # /search/summary
    add_index(:notifications, [:summary])
    add_index(:notifications, [:created_at])
  end
end

