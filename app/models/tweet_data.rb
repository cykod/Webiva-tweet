require 'timeout'

class TweetData
  def self.delayed_tweet_collector(args)
    begin
      Timeout::timeout(10) do
        if args[:screen_name]
          @data = Tweet::AdminController.module_options.twitter.user_timeline('screen_name' => args[:screen_name])
        else
          @data = Tweet::AdminController.module_options.twitter.user_timeline()
        end

        return nil unless @data

        @tweet_data = @data.map { |elm| dt = elm.to_hash; dt['user'] = dt['user'].to_hash; dt }

        limit = args[:limit].to_i
        @tweet_data = @tweet_data[0..(limit-1)] if limit > 0
      end
    rescue Exception => e
      return nil
    end

    tweets = {:tweets => @tweet_data}
    DomainModel.remote_cache_put(args, tweets)
    tweets
  end
end
