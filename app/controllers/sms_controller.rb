class SmsController < ApplicationController
  require 'net/http'

  def index
  end

  def send_sms
    http = Net::HTTP.new(URI.parse(AppConfig[Rails.env]['tropo']['api_url']).host)
    token = AppConfig[Rails.env]['tropo']['token']
    path = "/1.0/sessions?action=create&token=#{token}&msg=#{CGI::escape(params[:text])}&to=#{params[:phone]}&callerID=#{AppConfig[Rails.env]['tropo']['app_phone']}"
    resp = http.get(path)
    resp.code
    if resp.code == '200'
      flash[:notice] = 'Sent!'
    else
      flash[:error] = "#Fail! (error code: #{resp.code}) everything else: #{resp}"
    end
    redirect_to root_url
  end

  def tropo_callback
debugger
    sessions_object = Tropo::Generator.parse request.filtered_parameters
    msg = sessions_object[:session][:parameters][:msg]
    number_to_dial = sessions_object[:session][:parameters][:to]
    tropo = Tropo::Generator.new do
      message({
        :to => "#{number_to_dial}",
        :channel => 'TEXT',
        :network => 'SMS'}) do
          say :value => msg
        end
    end
    response = tropo.response
    render :json => JSON.parse(response)
  end

end
