class AddCompanyIdToResponse < ActiveRecord::Migration
  def change
    add_column :responses, :company_id, :integer
  end
end
