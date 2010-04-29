require 'twitter'

class TweetOauthProvider < OauthProvider::Base
  def self.oauth_provider_handler_info
    {
      :name => 'Twitter'
    }
  end

  def authorize_url
    request_token = self.client.set_callback_url self.redirect_uri

    self.session[self.session_name] = {:redirect_uri => self.redirect_uri, :oauth_token => request_token.token, :oauth_secret => request_token.secret}

    request_token.authorize_url :oauth_callback => self.redirect_uri
  end

  def access_token(params)
    begin
      access_token, access_secret = self.client.authorize_from_request self.session[self.session_name][:oauth_token], self.session[self.session_name][:oauth_secret], params[:oauth_verifier]
      self.session[self.session_name][:access_token] = access_token
      self.session[self.session_name][:access_secret] = access_secret
      true
    rescue OAuth::Error => e
      Rails.logger.error e
      false
    end
  end

  def client
    @client ||= Twitter::OAuth.new Tweet::AdminController.module_options.consumer_key, Tweet::AdminController.module_options.consumer_secret
  end

  def twitter
    return @twitter if @twitter
    self.client.authorize_from_access self.session[self.session_name][:access_token], self.session[self.session_name][:access_secret]
    @twitter = Twitter::Base.new self.client
  end

  def provider_id
    self.twitter_user_data[:id]
  end

  def get_oauth_user_data
    return @oauth_user_data if @oauth_user_data

    name = self.twitter_user_data[:name].to_s.strip.split(" ")
    first_name = nil
    last_name = nil
    if name.length > 1
      first_name = name[0]
      last_name = name[-1]
    elsif name.length == 1
      first_name = name[0]
    end

    @oauth_user_data = {
      :username => self.twitter_user_data[:screen_name],
      :profile_photo_url => self.twitter_user_data[:profile_image_url],
      :first_name => first_name,
      :last_name => last_name
    }
  end

  def get_profile_photo_url
    self.get_oauth_user_data[:profile_photo_url]
  end

  protected

  def twitter_user_data
    return @twitter_user_data if @twitter_user_data

    data = self.twitter.verify_credentials
    @twitter_user_data = data.to_hash.symbolize_keys
  end
end
