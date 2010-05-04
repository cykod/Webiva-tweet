

class Tweet::PageFeature < ParagraphFeature
  include ActionView::Helpers::DateHelper

  feature :tweet_page_tweets, :default_feature => <<-FEATURE
     <cms:tweets>
        <ul>
        <cms:tweet><li><cms:text/> <cms:view_link><cms:ago/></cms:view_link></li></cms:tweet>
        </ul>
      </cms:tweets>
  FEATURE
  

  def tweet_page_tweets_feature(data)
    webiva_feature(:tweet_page_tweets) do |c|
      c.loop_tag('tweet','tweets') { |t| data[:tweets] }
        c.h_tag('tweet:text') { |t| t.locals.tweet['text'] }
        c.date_tag('tweet:date',DEFAULT_DATETIME_FORMAT.t) do |t|  
          begin 
            tm = Time.parse(t.locals.tweet['created_at'])
          rescue Exception
            nil
          end
        end
        
        c.value_tag('tweet:ago') do |t|
          begin 
            tm = Time.parse(t.locals.tweet['created_at'])
            distance_of_time_in_words_to_now(tm) + " ago"
          rescue Exception
            nil
          end
        end
        
        c.link_tag('tweet:view') do |t|
          "http://twitter.com/#{t.locals.tweet['user']['screen_name']}/statuses/#{t.locals.tweet['id']}"
        end
    end
  end
  
  feature :tweet_page_user_tweet, :default_feature => <<-FEATURE
   <div class='twitter_box'>
    <h2>Post to Twitter</h2>

 <a href="<cms:twitter_url />"> Tweet This</a>

    </div>
  FEATURE
  

  def tweet_page_user_tweet_feature(data)
    webiva_feature(:tweet_page_user_tweet) do |c|
      c.value_tag('twitter_url') { |t| data[:twt] }
      c.form_error_tag('form:errors')
       
    end
  end


end
