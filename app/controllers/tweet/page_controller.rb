

class Tweet::PageController < ParagraphController

  editor_header 'Tweet Paragraphs'
  
  editor_for :tweets, :name => "Tweets", :feature => :tweet_page_tweets
  # editor_for :user_tweet, :name => "User tweet", :feature => :tweet_page_user_tweet

  class TweetsOptions < HashModel
    attributes :screen_name => nil,:cache_minutes => 10, :limit => 0
    
    integer_options :cache_minutes, :limit
    
    validates_numericality_of :cache_minutes, :limit
  end

  # Backwards compatability
  class TweetOptions < TweetsOptions
  end
  
  class UserTweetOptions < HashModel
      attributes :twt_source => nil, :twt_status => nil, :redirect_to_page_id => nil
      
      page_options :redirect_to_page_id
  end
end
