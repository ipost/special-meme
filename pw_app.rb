require 'json'
require 'password_protected_file'
require 'sinatra'

class PwApp < Sinatra::Base
  get '/' do
    erb :'index.html'
  end

  post '/create' do
    content_type :json
    begin
      status 201
      PasswordProtectedFile.create(file_name, password, [].to_json).data
    rescue => e
      status 403
      { error: error_message(e) }.to_json
    end
  end

  post '/open' do
    content_type :json
    begin
      status 201
      PasswordProtectedFile.open(file_name, password).data
    rescue => e
      status 403
      { error: error_message(e) }.to_json
    end
  end

  post '/save' do
    content_type :json
    begin
      status 201
      PasswordProtectedFile.open(file_name, password).tap { |p| p.data = data }.data
    rescue => e
      status 403
      { error: error_message(e) }.to_json
    end
  end

  def error_message(exception)
    case exception
    when PasswordProtectedFile::InvalidPasswordError then 'Please enter a valid password'
    when PasswordProtectedFile::IncorrectPasswordError then 'Incorrect Password'
    when PasswordProtectedFile::InvalidFilenameError then 'Please enter a valid identity'
    when PasswordProtectedFile::FilenameNotAvailableError then 'That identity is already in use'
    when PasswordProtectedFile::FileNotFoundError then 'That identity is not in use'
    else "Unknown failure"
    end
  end

  def parsed_params
    @parsed_params ||= JSON.parse(request.body.read)
  end

  def file_name
    @file_name ||= 'data/' + Digest::MD5.hexdigest(parsed_params['id'] || '')
  end

  def password
    @password ||= parsed_params['password']
  end

  def data
    @data ||= parsed_params['data'].to_json
  end
end
