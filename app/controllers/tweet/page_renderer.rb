
class Tweet::PageRenderer < ParagraphRenderer

  features '/tweet/page_feature'

  paragraph :tweets
  paragraph :user_tweet

  def tweets
  
    @options = paragraph_options(:tweets)
    
    result = renderer_cache(nil,@options.screen_name, :expires => @options.cache_minutes.to_i.minutes) do |cache|

      tweets = delayed_cache_fetch(TweetData, :delayed_tweet_collector, {:screen_name => @options.screen_name, :limit => @options.limit.to_i}, @options.screen_name, :expires => @options.cache_minutes.to_i.minutes)
      return render_paragraph :text => '' if ! tweets

      data = { :tweets => tweets[:tweets] }
      cache[:output] =  tweet_page_tweets_feature(data)
    end

    render_paragraph :text => result.output
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
