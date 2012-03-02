class CreateCompanies < ActiveRecord::Migration
  def change
    create_table :companies do |t|
      t.string :name
      t.string :role
      t.integer :primary_person_id
      t.integer :billing_person_id

      t.timestamps
    end
    
    add_column :people, :company_id, :integer
  end
end
