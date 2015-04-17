class Page
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paperclip

  field :number, type: Integer
  field :whole_text
  field :generated, type: Boolean
  field :filename

  has_many :words
  embedded_in :book

  def self.ungenerated
    where(generated: nil)
  end

  def self.generated
    where(generated: true)
  end

  has_mongoid_attached_file :attachment, :styles => { full: '2048x2048>',:medium => "300x300>", :thumb => "100x100>" }

  validates_attachment_content_type :attachment, :content_type => /\Aimage\/.*\Z/

end
