class CreateComputers < ActiveRecord::Migration
  def change
    create_table :computers do |t|
      t.integer :node
      t.string :title
      t.date :date
      t.string :link

      t.timestamps
    end
  end
end
