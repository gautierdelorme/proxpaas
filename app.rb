require 'sinatra'
require 'sinatra/activerecord'
require './lib/prox_client'
require './models/proxmox_app'
require 'fileutils'

set :database, 'sqlite3:db/proxpaas.sqlite3'

get '/apps' do
  ProxApp.all.to_json
end

post '/apps' do
  ProxApp.create!(
    ct_id: prox_client.create_and_start_ct(ProxApp.count)
  ).id.to_s
end

get '/apps/:id/url' do
  prox_app.ct_ip
end

post '/apps/:id/setup' do
  prox_app.update(ct_ip: params[:ip])
  prox_client.setup_ct prox_app.ct_ip
end

post '/apps/:id/deploy' do
  prox_client.upload_to_ct prox_app.ct_ip, params[:file][:tempfile].path
  prox_client.start_app_on_ct prox_app.ct_ip
end

def prox_app
  @prox_app ||= ProxApp.find params[:id]
end

def prox_client
  @prox_client ||= ProxClient.new
end
