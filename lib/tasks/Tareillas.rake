task :TweetlinkLoading => [:environment] do

  puts "Empezamos:"

  Twitter.user_timeline("objectivec_es", :count => 200, :exclude_replies => true).each do |tweet|
    Tweetlink.insert_tweet(tweet)
    puts "tweet_id: " + tweet.id.to_s
    @last_tweet = tweet.id
  end

  begin
    puts "A por otros 200..."
    tweets = Twitter.user_timeline("objectivec_es", :count => 200, :exclude_replies => true, :max_id => @last_tweet)
    tweets.each do |tweet|
      Tweetlink.insert_tweet(tweet)
      puts "tweet_id: " + tweet.id.to_s
      @last_tweet = tweet.id
    end
  end while tweets.length > 1

end

task :DeleteScriptTwitter => [:environment] do

  @tweetlinks = Tweetlink.all

  @tweetlinks.each do |tweetlink|
    puts "Antes" + tweetlink.oembed
    tweetlink.oembed = tweetlink.oembed.gsub(/<script(.*)script>/, ' ')
    puts "Despues" + tweetlink.oembed
    tweetlink.save
  end

end