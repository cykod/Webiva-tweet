require 'twitter'

class TweetData

  def initialize(paragraph_id,screen_name=nil,username=nil,password=nil) 
    @paragraph_id = paragraph_id
    @screen_name = screen_name
    @username = username
    @password = password
  end
  
  def tweet_container
    "TweetData#{@paragraph_id}"
  end
  
  def timeline_data(expires_in_minutes=10)
    @expires_at,@tweet_data = DataCache.get_container(tweet_container,'data')
    
    if !@expires_at || @expires_at < Time.now

      begin 
        if !@username.blank?
          @twt = Twitter::HTTPAuth.new(@username,@password)
          @twt_base = Twitter::Base.new(@twt)
          @twt_base.verify_credentials
        else
          @twt = Twitter::HTTPAuth.new(nil,nil)
          @twt_base = Twitter::Base.new(@twt)
        end
        
        if !@screen_name.blank?
          @data = @twt_base.user_timeline('screen_name' => @screen_name)
        else
          @data = @twt_base.user_timeline()
        end
        
        if @data
          # Turn it into a Hash so we're happy in the cache
          @tweet_data = @data.map { |elm| dt = elm.to_hash; dt['user'] = dt['user'].to_hash; dt } 
          
          DataCache.put_container(tweet_container,'data',[ Time.now + expires_in_minutes.minutes, @tweet_data ])
        end
        return @tweet_data
      rescue Twitter::TwitterError => e
        return @tweet_data # If we're over the rate limit, return the old data if we have it
      end
    end
    @tweet_data
  end
  
  def expire_timeline
    DataCache.expire_container(tweet_container)
  end

end
