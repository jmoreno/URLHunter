class AddTweetIdToTweetlinks < ActiveRecord::Migration
  def change
    add_column :tweetlinks, :tweet_id, :bigint
  end
end
