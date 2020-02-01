module RequestBuilders
  class Base
    class << self
      def build
        ::Typhoeus::Request.new(url, method: :get, headers: { Accept: "application/json" })
      end

      def url
        raise NotImplemented # Should be defined in sublings
      end
    end
  end
end
