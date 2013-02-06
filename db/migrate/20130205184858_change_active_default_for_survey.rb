class ChangeActiveDefaultForSurvey < ActiveRecord::Migration
  def up
    change_column_default(:surveys, :active, false)
  end

  def down
    change_column_default(:surveys, :active, true)
  end
end
