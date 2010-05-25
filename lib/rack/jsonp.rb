module Rack
  # Fix JSONP to correctly modify the Content-Length header if it exists
  class JSONP
    include Rack::Utils

    def call(env)
      status, headers, response = @app.call(env)
      headers = HeaderHash.new(headers)
      
      request = Rack::Request.new(env)
      if request.params.include?('callback')
        response = pad(request.params.delete('callback'), response)
        if headers['Content-Length']
          response = [response] if response.respond_to?(:to_str) # rack 0.4 compat
          length = response.to_ary.inject(0) { |len, part| len + bytesize(part) }
          headers['Content-Length'] = length.to_s
        end
      end
      [status, headers, response]
    end

  end
end
