class AddPinCodeToPeople < ActiveRecord::Migration
  def change
    add_column :people, :pin_code, :string

    Person.all.each do |person| 
    	person.generate_pin
    end
  end
end
