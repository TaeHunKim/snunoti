class CreateMysnus < ActiveRecord::Migration
  def change
    create_table :mysnus do |t|
      t.integer :node
      t.string :title
      t.date :date
      t.string :link

      t.timestamps
    end
  end
end
