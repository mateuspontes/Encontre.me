require 'rubygems'
require 'sinatra'
require 'twitter_oauth'

before do
	@user = session[:user]

	@client = TwitterOAuth::Client.new(
		:consumer_key => ENV['KEY'],
		:consumer_secret => ENV['SECRET'],
		:token => session[:access_token],
		:secret => session[:secret_token]
	)

	@rate_limit_status = @client.rate_limit_status
end

configure do
  enable :sessions
end

get '/' do
	if @user
		@user = @user
		erb :index
	else 
		"<a href='/connect'>sign on</a>"
	end
end

get '/connect' do
	request_token = @client.request_token

	session[:request_token] = request_token.token
	session[:request_token_secret] = request_token.secret

	redirect request_token.authorize_url
end

get '/auth' do
    @access_token = @client.authorize(
		session[:request_token],
		session[:request_token_secret]
	)
  
	if @client.authorized?
		session[:access_token] = @access_token.token
		session[:secret_token] = @access_token.secret
		session[:user] = true
	end
	
	redirect '/'
end

get '/logout' do
	session[:user] = nil
	session[:request_token] = nil
	session[:request_token_secret] = nil
	session[:access_token] = nil
	session[:secret_token] = nil
	redirect '/'
end