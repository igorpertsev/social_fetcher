module Requesters
  class Common
    attr_reader :hydra, :responses

    def call
      build_defaults
      hydra.run

      responses
    end

    def self.call
      new.call
    end

    private

    def build_defaults
      @hydra     = Typhoeus::Hydra.new
      @responses = { errors: {} }
      build_requests
    end

    def build_requests
      %w(facebook twitter instagram).each do |social_network|
        next unless (request = build_request_for(social_network))

        add_callback(social_network, request)
        hydra.queue(request)
      end
    end

    def add_callback(social_network, request)
      request.on_complete { |response| callback(social_network, response) }
    end

    def callback(social_network, response)
      if response.response_code == 200
        responses[social_network] = JSON.parse(response.body)
      else
        responses[:errors][social_network] = response.body
        responses[social_network] = []
      end
    end

    def build_request_for(social_network_name)
      "::RequestBuilders::#{social_network_name.camelcase}".constantize.build rescue nil
    end
  end
end
