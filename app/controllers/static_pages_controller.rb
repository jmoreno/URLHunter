class StaticPagesController < ApplicationController
  def index

    if(params.has_key?(:prey))
      @prey = Prey.find_by_user(params[:prey])
      @tweetlinks = Tweetlink.paginate(page: params[:page], :conditions => ['prey_id = ?', @prey.id]).order('tweet_id DESC').per_page(10)
    else
      @tweetlinks = Tweetlink.paginate(page: params[:page]).order('tweet_id DESC').per_page(10)
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @tweetlinks }
    end

  end

  def pullTweets

    Prey.all.each do |prey|
      Tweetlink.pull_tweets(prey)
    end
    redirect_to root_path
  end

end
