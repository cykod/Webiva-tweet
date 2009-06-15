require 'twitter'

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
    @tweet_data = @data_collector.timeline_data(@options.cache_minutes)
    
    if @tweet_data
      @tweet_data = @tweet_data[0..(@options.limit.to_i-1)] if @options.limit.to_i > 0
    end
                                      
    data = { :tweets => @tweet_data }
    
    render_paragraph :text => tweet_page_tweets_feature(data)
  end
  
  def user_tweet
    @options = paragraph_options(:user_tweet)
    
    @post = TweetUserPost.new(params["paragraph_#{paragraph.id}"])
    
    if request.post? && params["paragraph_#{paragraph.id}"]
      if @post.valid?
        @post.post_update!
        @posted = true
        if @options.redirect_to_page_url
          redirect_paragraph @options.redirect_to_page_url 
          return
        end
      end
    else
      @post.message = @options.default_message if @post.message.blank?
    end

    
    data = { :options => @options, :post => @post, :posted => @posted }
    
    render_paragraph :text => tweet_page_user_tweet_feature(data)
  end


end
