require 'twitter'
require 'timeout'


class Tweet::PageRenderer < ParagraphRenderer

  features '/tweet/page_feature'

  paragraph :tweets
  paragraph :user_tweet

  def tweets
  
    @options = paragraph_options(:tweets)
    
    @data_collector = TweetData.new(paragraph.id,
                                    @options.screen_name,
                                    @options.user_login,
                                    @options.user_password)
    @tweet_data = @data_collector.timeline_data(@options.cache_minutes,editor?)
    
    if @tweet_data
      @tweet_data = @tweet_data[0..(@options.limit.to_i-1)] if @options.limit.to_i > 0
    end
                                      
    data = { :tweets => @tweet_data }
    
    render_paragraph :text => tweet_page_tweets_feature(data)
  end
  
  def user_tweet

    @options = paragraph_options(:user_tweet)
    
    
    @twtr = "http://twitter.com/home?"
    @twt_source = @options.twt_source
    
    @twt_status="From:?",@options.twt_status
    @curr_page = Configuration.domain_link(paragraph_page_url)
    @twt = @twtr, @twt_source, @twt_status, @curr_page
    data = { :options => @options, :twt => @twt, :twt_source => @twt_source }
    
    render_paragraph :text => tweet_page_user_tweet_feature(data)
  end
  
  
end
