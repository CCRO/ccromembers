class AddSubQuestionToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :sub_question, :boolean, default: false
  end
end
