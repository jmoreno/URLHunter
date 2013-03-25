class StaticPagesController < ApplicationController
  def home

    @tweetlinks = Tweetlink.paginate(page: params[:page]).order('tweet_id DESC').per_page(10)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @tweetlinks }
    end

  end

  def pullTweets
    Tweetlink.pull_tweets
    redirect_to root_path
  end

end
