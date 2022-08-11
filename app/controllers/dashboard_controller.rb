# frozen_string_literal: true

class DashboardController < ApplicationController
  def index
    @connection_status = 'Not connected to database server'
  end

  def connect_to_database
    @connection_status = 'Could not connect to database server'
    begin
      # get the secret username and password for the database from vault
      vault_secret = []
      Vault.with_retries(Vault::HTTPConnectionError, Vault::HTTPError, attempts: 5) do
        vault_secret = Vault.logical.read(database_params[:secret_path])
      end
      @username = vault_secret.data[:username]
      @password = vault_secret.data[:password]

      # this takes a hash of options, almost all of which map directly
      # to the familiar database.yml in rails
      # See http://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/Mysql2Adapter.html
      @connection = Mysql2::Client.new(host: database_params[:host], username: @username, password: @password,
                                       database: database_params[:database])

      # check connection to database server by pinging it
      # if the ping fails, the connection will be nil
      # if the ping succeeds, the connection will be a Mysql2::Client object
      @connection_status = if @connection.ping
                             'Connected to database server'
                           else
                             'Could not connect to database server'
                           end
    rescue StandardError => e
      @connection_status = 'Could not connect to database server'
    end

    ## respond format is TURBO_STREAM
    respond_to do |format|
      format.turbo_stream
    end
  end

  def rotate_vault_secret
    @rotate_status = 'Could not rotate secret'
    begin
      # rotate the secret in vault
      Vault.with_retries(Vault::HTTPConnectionError, Vault::HTTPError, attempts: 5) do
        Vault.logical.write(params[:rotate_secrets][:rotate_path])
      end
      @rotate_status = 'Secret rotated'
    rescue StandardError => e
      @rotate_status = e.message
    end

    respond_to do |format|
      format.turbo_stream
    end
  end

  private

  def database_params
    params.require(:database).permit(:host, :database, :secret_path)
  end
end
