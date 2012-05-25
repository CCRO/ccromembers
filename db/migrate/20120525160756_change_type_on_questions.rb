class ChangeTypeOnQuestions < ActiveRecord::Migration
  def up
    rename_column :questions, :type, :response_type
  end

  def down
    rename_column :questions, :response_type, :type
  end
end
