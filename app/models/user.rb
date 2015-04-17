class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paperclip

  has_mongoid_attached_file :image
  validates_attachment_content_type :image, :content_type => /\Aimage\/.*\Z/

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  ## Database authenticatable
  field :email,              type: String, default: ""
  field :encrypted_password, type: String, default: ""

  field :name

  ## Recoverable
  field :reset_password_token,   type: String
  field :reset_password_sent_at, type: Time

  ## Rememberable
  field :remember_created_at, type: Time

  ## Trackable
  field :sign_in_count,      type: Integer, default: 0
  field :current_sign_in_at, type: Time
  field :last_sign_in_at,    type: Time
  field :current_sign_in_ip, type: String
  field :last_sign_in_ip,    type: String
  field :score,              type: Integer, default: 0



  ## Local

  field :default_local, type: String, default: 'en'

  ## Speed

  field :default_speed, type: Integer, default: 3

  has_many :authorizations

  has_many :games

  def self.new_with_session(params,session)
    if session["devise.user_attributes"]
      new(session["devise.user_attributes"],without_protection: true) do |user|
        user.attributes = params
        user.valid?
      end
    else
      super
    end
  end

  def self.from_omniauth(auth, current_user)
    authorization = Authorization.where(:provider => auth.provider, :uid => auth.uid.to_s, :token => auth.credentials.token, :secret => auth.credentials.secret).first_or_initialize
    if authorization.user.blank?
      user = current_user.nil? ? User.find_by(email: auth["info"]["email"]) : current_user
      if user.blank?
       user = User.new
       user.password = Devise.friendly_token[0,10]
       user.name = auth.info.name
       user.email = auth.info.email
       avatar_url = process_uri(auth.info.image)
       logger.error '---------------------------'
       logger.error avatar_url
       user.image = URI.parse(avatar_url)
       auth.provider == "twitter" ?  user.email = "random#{User.count}@email.com" : nil
       user.save
     end
     authorization.username = auth.info.nickname
     authorization.user_id = user.id
     authorization.save
   end
   authorization.user
 end

  ## Confirmable
  # field :confirmation_token,   type: String
  # field :confirmed_at,         type: Time
  # field :confirmation_sent_at, type: Time
  # field :unconfirmed_email,    type: String # Only if using reconfirmable

  ## Lockable
  # field :failed_attempts, type: Integer, default: 0 # Only if lock strategy is :failed_attempts
  # field :unlock_token,    type: String # Only if unlock strategy is :email or :both
  # field :locked_at,       type: Time

  private

    def self.process_uri(uri)
      require 'open-uri'
      require 'open_uri_redirections'
      open(uri, :allow_redirections => :safe) do |r|
        r.base_uri.to_s
      end
    end
end
