require 'freshbooks.rb'
class Freshbooks
  def get_client(fresh_books_id)
    setup
    c = FreshBooks::Client.get(fresh_books_id)
    @fbclient = FBClient.new(c.client_id,c.username,c.first_name,c.last_name,c.organization,c.credit,c.p_street1,c.p_street2,c.p_country,c.p_state,c.p_city,c.p_code,c.s_street1,c.s_street2,c.s_country,c.s_state,c.s_city,c.s_code,c.email,c.home_phone,c.work_phone,c.mobile,c.fax,c.links.client_view,c.links.view,c.updated,c.notes)
  end
  
  def get_client_amount_outstanding(freshbooks_id)
    setup
    if fbinvoices = FreshBooks::Client.get(freshbooks_id).try(:invoices)
      @amount_outstanding = 0
      fbinvoices.each do |i|
        @amount_outstanding += i.amount_outstanding
      end
      @amount_outstanding
    end
  end
  
  def get_client_list
    setup
    fbclients = FreshBooks::Client.list.sort_by{|c| c.organization }
    @fbclients =[]
    fbclients.each do |c|
      @fbclients << FBClient.new(c.client_id,c.username,c.first_name,c.last_name,c.organization,c.credit,c.p_street1,c.p_street2,c.p_country,c.p_state,c.p_city,c.p_code,c.s_street1,c.s_street2,c.s_country,c.s_state,c.s_city,c.s_code,c.email,c.home_phone,c.work_phone,c.mobile,c.fax,c.links.client_view,c.links.view,c.updated,c.notes)
    end
    @fbclients
  end
  
  def get_invoice_list
    setup
    fbinvoices = FreshBooks::Invoice.list
    @fbinvoices =[]
    fbinvoices.each do |i|
      @fbinvoices << FBInvoice.new(i.invoice_id,i.recurring_id,i.client_id,i.po_number,i.paid,i.number,i.amount,i.amount_outstanding,i.discount,i.currency_code,i.status,i.date,i.organization,i.first_name,i.last_name,i.p_street1,i.p_street2,i.p_country,i.p_state,i.p_city,i.p_code,i.links.client_view,i.links.view,i.links.edit,i.updated,i.notes,i.lines)
    end
    @fbinvoices
  end
  
  private 
    def setup
      FreshBooks::Base.establish_connection(APP_CONFIG['freshbooks']['link'],APP_CONFIG['freshbooks']['token'])
    end
end

class FBClient
  attr_accessor :client_id, :username, :first_name, :last_name, :organization, :credit, :p_street1, :p_street2, :p_country, :p_state, :p_city, :p_code, :s_street1, :s_street2, :s_country, :s_state, :s_city, :s_code, :email, :home_phone, :work_phone, :mobile, :fax, :client_view, :view, :updated, :notes
  def initialize(client_id,username,first_name, last_name,organization,credit,p_street1,p_street2,p_country,p_state,p_city,p_code,s_street1,s_street2,s_country,s_state,s_city,s_code,email,home_phone,work_phone,mobile,fax,client_view,view,updated,notes)
    @client_id = client_id
    @username = username
    @first_name = first_name
    @last_name = last_name
    @organization = organization
    @credit = credit
    @p_street1 = p_street1
    @p_street2 = p_street2
    @p_country = p_country
    @p_state = p_state
    @p_city = p_city
    @p_code = p_code
    @s_street1 = s_street1
    @s_street2 = s_street2
    @s_country = s_country
    @s_state = s_state
    @s_city = s_city
    @s_code = s_code 
    @email = email
    @home_phone = home_phone
    @work_phone = work_phone
    @mobile = mobile
    @fax = fax
    @client_view = client_view
    @view = view
    @updated = updated
    @notes = notes 
  end
 
  def full_name
    @last_name + ", " + @first_name
  end
end

class FBInvoice
  attr_accessor :invoice_id, :recurring_id, :client_id, :po_number, :paid, :number, :amount, :amount_outstanding, :discount, :currency_code, :status, :date, :organization, :first_name, :last_name, :p_street1, :p_street2, :p_country, :p_state,:p_city, :p_code, :client_view, :view, :edit,:updated,:notes, :lines
  def initialize(invoice_id,recurring_id,client_id,po_number,paid,number,amount,amount_outstanding,discount,currency_code,status,date,organization,first_name,last_name,p_street1,p_street2,p_country,p_state,p_city,p_code,client_view,view,edit,updated,notes,lines)
    @invoice_id = invoice_id
    @recurring_id = recurring_id
    @client_id = client_id
    @po_number = po_number
    @paid = paid
    @number = number
    @amount = amount
    @amount_outstanding = amount_outstanding
    @discount = discount
    @currency_code = currency_code
    @status = status
    @date = date
    @organization = organization
    @first_name = first_name
    @last_name = last_name
    @p_street1 = p_street1
    @p_street2 = p_street2
    @p_country = p_country
    @p_state = p_state
    @p_city = p_city
    @p_code = p_code
    @client_view = client_view
    @view = view
    @edit = edit
    @updated = updated
    @notes = notes
    #lines.each do |l|
      #@lines << FBInvoiceLines.new(l.name,l.amount,l.quantity,l.unit_cost,l.description,l.tax1_name,l.tax1_percent,l.tax2_name,l.tax2_percent)
    #end 
  end
 
  def full_name
    @last_name + ", " + @first_name
  end
end

class FBInvoiceLines
  attr_accessor :name, :amount, :quantity, :unit_cost, :description, :tax1_name, :tax1_percent, :tax2_name, :tax2_percent
  def initialize(name,amount,quantity,unit_cost,description,tax1_name,tax1_percent,tax2_name,tax2_percent)
    @name = name
    @amount = amount
    @quantity = quantity
    @unit_cost = unit_cost
    @description = description
    @tax1_name = tax1_name
    @tax1_percent = tax1_percent
    @tax2_name = tax2_name
    @tax2_percent = tax2_percent
  end
end
