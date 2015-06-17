require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/flash'
require 'omniauth-github'

require_relative 'config/application'

Dir['app/**/*.rb'].each { |file| require_relative file }

helpers do
  def current_user
    user_id = session[:user_id]
    @current_user ||= User.find(user_id) if user_id.present?
  end

  def signed_in?
    current_user.present?
  end
end

def set_current_user(user)
  session[:user_id] = user.id
end

def authenticate!
  unless signed_in?
    flash[:notice] = 'You need to sign in if you want to do that!'
    redirect '/'
  end
end

def meetup_list
  results = Meetup.all.order(:name)
  results.to_a
end

# def meetup_save(input)
#   # do a join to get the user id in the same table
#   # if user id is not nill, save the record,
#   # otherwise flash an error msg that we need to be signed in to create a meetup
#   if
#     data = input[[:name],[:description],[:location]]
#     meetup_new = Meetup.create()
#   end
# end


get '/' do
  @meetups = meetup_list
  erb :index
end

get '/new' do
  erb :new
end

post '/new' do
  new_meetup = Meetup.new(name: params[:name], description: params[:description], location: params[:location])

  if authenticate!
  else
    new_meetup.save
  end
  redirect '/'
end

get '/auth/github/callback' do
  auth = env['omniauth.auth']

  user = User.find_or_create_from_omniauth(auth)
  set_current_user(user)
  flash[:notice] = "You're now signed in as #{user.username}!"

  redirect '/'
end

get '/sign_out' do
  session[:user_id] = nil
  flash[:notice] = "You have been signed out."

  redirect '/'
end

get '/example_protected_page' do
  authenticate!
end


get '/:id' do
  @specific_meetup = Meetup.find(params[:id])
  erb :show
end
