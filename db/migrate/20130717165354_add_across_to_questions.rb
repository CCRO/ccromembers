class AddAcrossToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :across, :boolean, default: false
  end
end
