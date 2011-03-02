class Order < ActiveRecord::Base
  belongs_to :customer, :class_name => "Customer", :foreign_key => "customer_id"
  belongs_to :user, :class_name => "User", :foreign_key => "user_id"
  belongs_to :assigned_company, :class_name => "Company", :foreign_key => "assigned_company_id"
  belongs_to :parent_company, :class_name => "Company", :foreign_key => "parent_company_id"
  has_many :items
  
  scope :company, lambda { |company| {:conditions => ["assigned_company_id = ?", company.id] }}
  scope :open, where(:closed => false)
  
  
  attr_accessible :assigned_company_id, :parent_company_id, :customer_id, :user_id, :closed, :closed_date, :payment_type, :total_cost, :total_amount, :amount_paid, :override, :customer_attributes
  
  accepts_nested_attributes_for :customer, :allow_destroy => true, :reject_if => proc { |obj| obj.blank? }
  
    
    PAYMENTTYPES = %w[cash check credit_card]
    
    # totals only items that are not nested in parent_id like service groups.
    def total_price
      # convert to array so it doesn't try to do sum on database directly
      removed_subitems = self.items.where(:parent_id => nil)
      removed_subitems.to_a.sum(&:full_price)
    end
    
    # totals only items that are not nested in parent_id like service groups.
    def true_cost
      # convert to array so it doesn't try to do sum on database directly
      removed_subitems = items.where("itemable_type != ?", "ServiceGroup")
      removed_subitems.to_a.sum(&:full_price)
    end
  
end