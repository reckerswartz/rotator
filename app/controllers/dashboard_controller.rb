class DashboardController < ApplicationController
  def index
    @connection_status = "Not connected to database server"
  end

  def connect_to_database
    # this takes a hash of options, almost all of which map directly
    # to the familiar database.yml in rails
    # See http://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/Mysql2Adapter.html
    @connection = Mysql2::Client.new(:host => database_params[:host], :username => database_params[:username], :password => database_params[:password], :database => database_params[:database])

    # check connection to database server by pinging it
    # if the ping fails, the connection will be nil
    # if the ping succeeds, the connection will be a Mysql2::Client object
    if @connection.ping
      @connection_status = "Connected to database server"
    else
      @connection_status = "Could not connect to database server"
    end

    ## respond format is TURBO_STREAM
    respond_to do |format|
      format.turbo_stream
    end
  end

  private

  def database_params
    params.require(:database).permit(:host, :username, :password, :database)
  end
end
