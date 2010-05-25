module Rack
  # Fix rack-contrib/jsonp
  class JSONP
    include Rack::Utils

    def call(env)
      status, headers, response = @app.call(env)
      headers = HeaderHash.new(headers)
      request = Rack::Request.new(env)
      
      if is_json?(headers['Content-Type']) && has_callback?(request.params)
        response = pad(request.params.delete('callback'), response)

        # No longer json, its javascript!
        headers['Content-Type'].gsub!('json', 'javascript')
        
        # Set new Content-Length, if it was set before we mutated the response body
        if headers['Content-Length']
          # Code from Rack::ContentLength
          response = [response] if response.respond_to?(:to_str) # rack 0.4 compat
          length = response.to_ary.inject(0) { |len, part| len + bytesize(part) }
          headers['Content-Length'] = length.to_s
        end
      end
      [status, headers, response]
    end
    
    def is_json?(header)
      header.include?('application/json')
    end
    
    def has_callback?(params)
      params.include?('callback')
    end

  end
end
