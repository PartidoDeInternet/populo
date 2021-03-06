class Organization < ActiveRecord::Base
  attr_accessible :name, :description, :spokesman
  has_many :represented_users, :class_name => "User", :foreign_key => :representer_id
  belongs_to :spokesman, :class_name => "User"
  has_many :opinions
  
  validates_presence_of :spokesman
  
  def has_opined_for?(proposal)
    opinions.map(&:proposal).include?(proposal)
  end
  
  def opinion_for(proposal)
    opinions.find_by_proposal_id(proposal)
  end
end
