task :PreysLoad => [:environment] do

  puts "Empezamos:"
  preys = ["ObjectiveC_es", "AprendeGit"]

  preys.each do |user|
    Prey.find_or_create_by_user(user)
  end

end

task :ObjectiveC_esLoad => [:environment] do

  puts "Empezamos:"
  @user = Prey.find_by_user("ObjectiveC_es")

  Twitter.user_timeline(@user.user, :count => 200, :exclude_replies => true).each do |tweet|
    puts "tweet_id: " + tweet.id.to_s
    Tweetlink.insert_tweet(tweet, @user)
    @last_tweet = tweet.id
  end

  begin
    puts "A por otros 200..."
    tweets = Twitter.user_timeline(@user.user, :count => 200, :exclude_replies => true, :max_id => @last_tweet)
    tweets.each do |tweet|
      puts "tweet_id: " + tweet.id.to_s
      Tweetlink.insert_tweet(tweet, @user)
      @last_tweet = tweet.id
    end
  end while tweets.length > 1

end

task :AprendeGitLoad => [:environment] do

  puts "Empezamos:"
  @user = Prey.find_by_user("AprendeGit")
  puts "Hola " + @user.to_s

  Twitter.user_timeline(@user.user, :count => 200, :exclude_replies => true).each do |tweet|
    puts "tweet_id: " + tweet.id.to_s
    Tweetlink.insert_tweet(tweet, @user)
    @last_tweet = tweet.id
  end

  begin
    puts "A por otros 200..."
    tweets = Twitter.user_timeline(@user.user, :count => 200, :exclude_replies => true, :max_id => @last_tweet)
    tweets.each do |tweet|
      puts "tweet_id: " + tweet.id.to_s
      Tweetlink.insert_tweet(tweet, @user)
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

task :LinkToFirstPrey => [:environment] do

  @user = Prey.find_by_user("ObjectiveC_es")
  @tweetlinks = Tweetlink.all

  @tweetlinks.each do |tweetlink|
    tweetlink.prey = @user
    tweetlink.save
  end

end