class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.belongs_to :notification, index: true
      t.string   :label, limit: 15
      t.string   :ip, limit: 40
      t.timestamp :created_at, null: false
    end
    add_index(:tags, [:ip])
    add_index(:tags, [:label])
  end
end

