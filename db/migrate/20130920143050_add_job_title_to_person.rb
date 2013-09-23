class AddJobTitleToPerson < ActiveRecord::Migration
  def change
    add_column :people, :job_title, :string
  end
end
