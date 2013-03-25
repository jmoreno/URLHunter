class Tweetlink < ActiveRecord::Base
  attr_accessible :content, :screen_name, :tweet_id, :profile_image, :tweet_created_at, :oembed

  def self.first_time
    Twitter.user_timeline("objectivec_es", :count => 3200, :exclude_replies => true).each do |tweet|
      insert_tweet(tweet)
    end
  end

  def self.pull_tweets
    Rails.cache.fetch("timeline/objectivec_es", :expires_in => 5.minutes) do
      Twitter.user_timeline("objectivec_es", :count => 200, :exclude_replies => true, :since_id => maximum(:tweet_id)).each do |tweet|
        insert_tweet(tweet)
      end
    end
  end

  def self.insert_tweet(tweet)
    if tweet.retweet?
      tweet = tweet.retweeted_status
    end
    unless exists?(tweet_id: tweet.id)
      if tweet.urls.any?
        oembed = Twitter.oembed(tweet.id, :maxwidth => 550)
        @oembed = oembed.html.gsub(/<script(.*)script>/, ' ')
        create!(
           tweet_id: tweet.id,
           content: tweet.text,
           oembed: @oembed,
           screen_name: tweet.user.screen_name,
           profile_image: tweet.user.profile_image_url,
           tweet_created_at: tweet.created_at,
        )
      end
    end
  end

end
