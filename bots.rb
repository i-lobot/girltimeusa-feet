require 'twitter_ebooks'
require './girltime.rb'

# This is an example bot definition with event handlers commented out
# You can define and instantiate as many bots as you like

class MyBot < Ebooks::Bot
  # Configuration here applies to all MyBots
  def configure
    # Consumer details come from registering an app at https://dev.twitter.com/
    # Once you have consumer details, use "ebooks auth" for new access tokens
    self.consumer_key = ENV['CONSUMER_KEY']
    self.consumer_secret = ENV['CONSUMER_SECRET']


    # Users to block instead of interacting with
    self.blacklist = %w( )

    # Range in seconds to randomize delay when bot.delay is called
    self.delay_range = 12..160
    #self.delay_range = 1..1
  end

  def on_startup
    load_model!
    @logic = GirlTime.new
    statement = @model.make_statement(140)
    tweet(statement)
    scheduler.every '2h' do
      statement = @model.make_statement(140)
      tweet(statement) if rand(0..4)==0
    end
  end

  def on_message(dm)
    # Reply to a DM
    # reply(dm, "secret secrets")
  end

  def on_follow(user)
    # Follow a user back
     follow(user.screen_name)
  end

  def on_mention(tweet)
    # Reply to a mention
    prob = 0.75
    if !tweet.retweet? and rand() <= prob
      delay do
        reply(tweet, meta(tweet).reply_prefix + @model.make_response(tweet.text, meta(tweet).limit))
      end
    end

  end


  def on_timeline(tweet)
    # Reply to a tweet in the bot's timeline
    
    #if tweet.text.match /#girltimeusa/i and meta(tweet).reply_prefix.match /@namastegeoduck/i
    if tweet.text.match /#girltime/i and tweet.retweet?
      delay do
        txt = @model.make_response(tweet.text, 80) + " @lilbthebasedgod" 
        txt = txt + " #GirlTimeUSA" if ! txt.match /GirlTimeUSA/i
        pictweet(txt, @logic.generate)
        return nil
      end 
    end

    return nil if tweet.text.match /@/ 
    return nil if tweet.retweet? 
    
    tokens = Ebooks::NLP.tokenize(tweet.text).collect { |x| x.downcase }
    count = (tokens & @top100).uniq.count
    prob = 0.05*count
    if count
        delay do
          favorite(tweet) if rand <= prob
        end
    end

  end


  private
  def load_model!
    return if @model
    @model_path ||= "model/bot.model"
    log "Loading model #{@model_path}"
    @model = Ebooks::Model.load(@model_path)
    @top100 = @model.keywords.take(100).collect { |x| x.downcase }
  end

end

# Make a MyBot and attach it to an account
MyBot.new("fitEmuTease") do |bot|
  bot.access_token = ENV['ACCESS_TOKEN']
  bot.access_token_secret = ENV['ACCESS_TOKEN_SECRET']
end
