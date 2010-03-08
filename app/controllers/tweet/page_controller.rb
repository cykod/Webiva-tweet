

class Tweet::PageController < ParagraphController

  editor_header 'Tweet Paragraphs'
  
  editor_for :tweets, :name => "Tweets", :feature => :tweet_page_tweets
  editor_for :user_tweet, :name => "User tweet", :feature => :tweet_page_user_tweet

  class TweetsOptions < HashModel
    attributes :user_login => nil, :user_password => nil, :screen_name => nil,:cache_minutes => 10, :limit => 0
    
    integer_options :cache_minutes, :limit
    
    validates_numericality_of :cache_minutes, :limit
  end

  # Backwards compatability
  class TweetOptions < TweetsOptions
  end
  
  def tweets
    
    if params[:tweets] && params[:tweets][:user_password].blank?
      @paragraph.data||={}
      params[:tweets][:user_password] = @paragraph.data[:user_password]
    end
    
    @options = TweetOptions.new(params[:tweets] || @paragraph.data)
    if params[:tweets] && @options.valid?
      @data_collector = TweetData.new(paragraph.id)
      @data_collector.expire_timeline
      return if handle_paragraph_update(@options)
    end
    
    @options.user_password = nil unless params[:tweets]
  end
  
  
  class UserTweetOptions < HashModel
      attributes :twt_source => nil, :twt_status => nil, :redirect_to_page_id => nil
      
      page_options :redirect_to_page_id
  end

end
