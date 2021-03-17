class Janrain
  include Singleton

  def login(login_params={})
      params = { flow: Cfg.config['flow_name'],
        flow_version: Cfg.config['flow_version'],
        client_id: Cfg.config['client_id'],
        redirect_uri: 'http://localhost', response_type: 'token', form: 'signInForm', locale: 'en-US',
        signInEmailAddress: login_params[:username], currentPassword: login_params[:password] }

    uri = URI("#{Cfg.config['url']}/oauth/auth_native_traditional")
    # puts "uri: #{uri.inspect}"
    response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
      req = Net::HTTP::Post.new(uri)
      req['Content-Type'] = 'application/json'
      req.body = params.to_json
      http.request(req)
    end
    puts "body: #{response.body.inspect}"

    res = JSON.parse(response.body) rescue {}
    puts "login response.to_json:\n #{res.to_json}"

    res
  end

  def stub_login(login_params)
    begin
      row = Cfg.get_random_test_user
      stub_details = if login_params[:casl_type].to_s == 'all'
                        Cfg.config['accept_all_casl@demo.com']
                      else
                        Cfg.config['decline_all_casl@demo.com']
                      end
      stub_details['capture_user']['email'] = row[1]
      stub_details['capture_user']['dtcGuid'] = row[0]
      stub_details['capture_user']['uuid'] = row[0]
      stub_details
    rescue Exception => e
      puts "ERROR! Janrain.stub_login EXCEPTION: #{e.message}, Backtrace: #{e.backtrace.inspect}"
      nil
    end
  end

end