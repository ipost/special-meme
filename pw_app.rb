require 'json'
require 'password_protected_file'
require 'sinatra'

class PwApp < Sinatra::Base
  get '/' do
    erb :'index.html'
  end

  post '/create' do
    content_type :json
    new_data = [].to_json
    PasswordProtectedFile.create(file_name, password, new_data).data
    #todo: check if create fails
  end

  post '/open' do
    content_type :json
    PasswordProtectedFile.open(file_name, password).data
    #todo: check if open fails
  end

  post '/save' do
    PasswordProtectedFile.open(file_name, password).data = data
    #todo: check if open or save fail
  end

  def parsed_params
    @parsed_params ||= JSON.parse(request.body.read)
  end

  def file_name
    @file_name ||= 'data/' + Digest::MD5.hexdigest(parsed_params['id'])
  end

  def password
    @password ||= parsed_params['password']
  end

  def data
    @data ||= parsed_params['data'].to_json
  end
end
