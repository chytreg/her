module Her
  module Testing
    module Macros
      module RequestMacros
        def ok!(body)
          [200, {}, body.to_json]
        end

        def error!(body)
          [400, {}, body.to_json]
        end

        def params(env)
          @params ||= Faraday::Utils.parse_query(env[:body]).with_indifferent_access
        end
      end
    end
  end
end
