require 'twitter'

class TweetUserPost < HashModel
  
  attributes :username => nil, :password => nil, :message => nil
  validates_presence_of :username, :password, :message
  validates_length_of :message, :maximum => 140
  
  def validate
    if !self.username.blank? && !self.password.blank? && !self.message.blank?
      @twt = Twitter::HTTPAuth.new(self.username,self.password)
      @twt_base = Twitter::Base.new(@twt)
      begin
        @twt_base.verify_credentials
      rescue Twitter::Unauthorized
        self.errors.add(:password,'is invalid')
      end
    end
  end
  
  def post_update!
    validate unless @twt
    
    @twt_base.update(self.message)
  end

end
