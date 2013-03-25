class RemoveTweetIdFromTweetlinks < ActiveRecord::Migration
  def up
    remove_column :tweetlinks, :tweet_id
  end

  def down
    add_column :tweetlinks, :tweet_id, :bigint
  end
end
