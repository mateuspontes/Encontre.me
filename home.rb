require 'rubygems'
require 'sinatra'
require 'twitter_oauth'
require 'json'

before do
	@user = session[:user]

	@client = TwitterOAuth::Client.new(
		:consumer_key => ENV['KEY'] || '99lIp0OaxjMTF1ooVnZqvw',
		:consumer_secret => ENV['SECRET'] || '9S1m9TOl1lnKsom689P1kVOLojyAPc6bRnnKBv5BBo',
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
	else 
		@user = ''
	end
  erb :index
end

post '/save' do
  x = params[:x]
  y = params[:y]
  
  return x
end

get '/all' do
  content_type :json
  { :nome => 'mateuspontes', :x => '250', :y => '250' }.to_json
  { :nome => 'caironoleto', :x => '400', :y => '250' }.to_json
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