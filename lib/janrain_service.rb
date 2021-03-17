module JanrainService
  class API < Grape::API

    version 'v1', using: :path, vendor: 'janrain_test'
    format :json

    resource :heartbeat do
      get do
        puts "get heartbeat"
        $REQ_ID = "HBT-#{rand(1000000000..9999999999)}"
        @response = { success: true, request_id: $REQ_ID }
      end
    end # end heartbeat

    resource :janrain_login do
      get do
        puts "janrain_login  p #{params.inspect}"
        $REQ_ID = "JL-#{rand(1000000000..9999999999)}"
        begin
          results = Janrain.instance.login({ username: params['username'], password: params['password'] })
        rescue Exception => e
          puts "e: #{e.message}, #{e.backtrace}"
        end
        @response = { success: true, request_id: $REQ_ID, res: results }
      end
    end # end janrain_login


    resource :stub_login do
      get do
        puts "stub_login p #{params.inspect}, casl_type parameter can be 'all' or 'none'"
        $REQ_ID = "SL-#{rand(1000000000..9999999999)}"
        results = Janrain.instance.stub_login({ casl_type: params['casl_type'], username: params['username'], password: params['password'] })
        @response = { success: true, request_id: $REQ_ID, res: results }
      end
    end # end stub_login

  end # end api
end # end service