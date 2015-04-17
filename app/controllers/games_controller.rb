class GamesController < ApplicationController

  def play_random
    @game = Game.new
    @lang = 'ara'
    @words = Word.asc(:played).take(20)
    @game.words = @words
    @game.save
    @words.map(&:inc_played)
    render 'play'
  end

  def index
    @game = Game.new
    @lang = 'ara'
    @words = Word.asc(:played).take(20)
    @game.words = @words
    @game.save
    @words.map(&:inc_played)
    render 'play'
  end


  def submit_score
    total = 0
    game = Game.find params[:game]
    params[:data].to_a.each do |e|
      id = e[1][:id]
      guess = e[1][:guess]
      word = Word.find(id)
      score = word.add_guess guess
      total += score
    end
    time = params[:time].to_i
    total *= 10
    total -= (time*2)
    game.score = total
    game.guesses = params[:data].to_a
    game.time = time
    game.user = current_user if user_signed_in?
    game.ip = request.env['REMOTE_ADDR']
    game.save
    if user_signed_in?
      current_user.score += total
      current_user.save
    end
    render json: {total: I18n.t(:score_is, total: total, time: time), score: total, time: time}
  end


  def rankings
    if params[:today]
      @games = Game.registered.where(:created_at.gt => DateTime.now.at_beginning_of_day).desc(:score)
      @users = @game.map(&:user)
    else
      @users = User.desc(:score)
    end

  end

end