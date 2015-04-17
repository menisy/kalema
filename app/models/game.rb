class Game
  include Mongoid::Document
  include Mongoid::Timestamps


  belongs_to :user
  has_and_belongs_to_many :words

  scope :registered, -> { where(:user_id.ne => nil) }

  field :guesses, type: Array
  field :score
  field :time
  field :ip
end
