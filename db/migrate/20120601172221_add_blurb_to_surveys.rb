class AddBlurbToSurveys < ActiveRecord::Migration
  def change
    add_column :surveys, :blurb, :text

  end
end
