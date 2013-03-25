class AddOembedToTweetlink < ActiveRecord::Migration
  def change
    add_column :tweetlinks, :oembed, :text
  end
end
