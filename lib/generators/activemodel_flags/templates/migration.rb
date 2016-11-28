class AddFlagsTo<%= table_name.camelize %> < ActiveRecord::Migration

  def up
    add_column :<%= table_name %>, :flags, :text, default: '{}'
  end

  def down
    remove_column :<%= table_name %>, :flags
  end
end
