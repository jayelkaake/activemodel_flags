class AddFlagsTo<%= table_name.camelize %> < ActiveRecord::Migration

  def up
    add_column :<%= table_name %>, :flags, :text

    <%= class_name.camelize.singularize %>.all.each do |obj|
      obj.update!(flags: {})
    end
  end

  def down
    remove_column :<%= table_name %>, :flags
  end
end
