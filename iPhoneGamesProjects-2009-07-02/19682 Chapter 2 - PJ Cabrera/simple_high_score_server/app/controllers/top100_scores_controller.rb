class Top100ScoresController < ApplicationController
  # GET /top_100_scores
  # GET /top_100_scores.xml
  def index
    @high_scores = HighScore.find(:all, :limit => 100, :order => 'score desc')

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @high_scores }
    end
  end

end
