class AddProfileImageAndCreatedAtToTweetlink < ActiveRecord::Migration
  def change
    add_column :tweetlinks, :profile_image, :string
    add_column :tweetlinks, :tweet_created_at, :string
  end
end
