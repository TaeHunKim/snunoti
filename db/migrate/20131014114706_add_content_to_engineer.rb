class AddContentToEngineer < ActiveRecord::Migration
  def change
    add_column :engineers, :content, :string
  end
end
