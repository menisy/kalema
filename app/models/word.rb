require 'amatch'

class Word
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paperclip
  include Amatch

  field :text
  field :accuracy, type: Integer
  field :ocr_text
  field :guesses, type: Array, default: []
  field :verified, type: Boolean
  field :filename
  field :played, type: Integer, default: 0
  field :lang


  has_and_belongs_to_many :games
  has_mongoid_attached_file :image
  before_create :set_lang
  belongs_to :page
  validates_attachment_content_type :image, :content_type => /\Aimage\/.*\Z/


  def self.lang lang
    where(lang: lang)
  end

  def self.verified
    where(verified: true)
  end

  def set_lang
    self.lang = self.page.book.lang
  end

  def inc_played
    self.played += 1
    save
  end

  def max_guess
    mx = 0;
    mxIndx = 0;
    guesses.each_with_index do |g, i|
      if g[1] > mx
        mx = g[1]
        mxIndx = i
      end
    end
    guesses[mxIndx][0] if !guesses[mxIndx].nil?
  end

  def add_guess word
    m = Levenshtein.new(word)
    found = false
    score = word.length
    guesses.each do |guess|
      st = guess[0]
      dist = m.match(st)
      if dist == 0
        guess[1] = guess[1] + word.length * 2;
        score = word.length * 2
      else
        guess[1] -= dist
        score -= dist if not found
      end
    end
    guesses << [word, score] if not found
    save
    score
  end
end
