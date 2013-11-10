class AddColumnToMysnuComputer < ActiveRecord::Migration
  def change
    add_column :mysnus, :content, :string
    add_column :computers, :content, :string
  end
end
