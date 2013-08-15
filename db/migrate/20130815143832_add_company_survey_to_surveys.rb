class AddCompanySurveyToSurveys < ActiveRecord::Migration
  def change
    add_column :surveys, :company_survey, :boolean
  end
end
