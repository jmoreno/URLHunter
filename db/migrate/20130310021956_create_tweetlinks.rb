class CreateTweetlinks < ActiveRecord::Migration
  def change
    create_table :tweetlinks do |t|
      t.integer :tweet_id
      t.string :screen_name
      t.text :content

      t.timestamps
    end
  end
end
