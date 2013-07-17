class AddTitleToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :title, :boolean, default: false
  end
end
