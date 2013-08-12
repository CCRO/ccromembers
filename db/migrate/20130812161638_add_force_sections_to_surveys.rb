class AddForceSectionsToSurveys < ActiveRecord::Migration
  def change
    add_column :surveys, :force_sections, :boolean, default: false
  end
end
