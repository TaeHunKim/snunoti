class CreateEngineers < ActiveRecord::Migration
  def change
    create_table :engineers do |t|
      t.integer :node
      t.string :title
      t.date :date
      t.string :link

      t.timestamps
    end
  end
end
