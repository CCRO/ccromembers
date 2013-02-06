class AddActiveAndLevelToSurvey < ActiveRecord::Migration
  def change
    add_column :surveys, :active, :boolean, :default => true

    add_column :surveys, :level, :string, :default => "basic"

  end
end
