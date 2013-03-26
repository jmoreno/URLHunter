class AddPreyToTweetlink < ActiveRecord::Migration
  def change
    change_table :tweetlinks do |t|
      t.references :prey
    end
  end
end
