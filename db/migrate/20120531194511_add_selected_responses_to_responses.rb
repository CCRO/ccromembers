class AddSelectedResponsesToResponses < ActiveRecord::Migration
  def change
    add_column :responses, :selected_responses, :text

  end
end
