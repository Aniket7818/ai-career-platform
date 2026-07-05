require "net/http"
require "json"

module Ai
  module Providers
    class GeminiProvider < BaseProvider
      def generate(prompt:, model:, temperature:, max_output_tokens:)
        api_key = @config["api_key"]
        raise AiService::ConfigurationError, "GEMINI_API_KEY is missing" if api_key.blank?

        model ||= @config["model"] || "gemini-2.5-flash"
        url = URI("https://generativelanguage.googleapis.com/v1beta/models/#{model}:generateContent?key=#{api_key}")

        body = {
          contents: [ { parts: [ { text: prompt } ] } ],
          generationConfig: { temperature: temperature, maxOutputTokens: max_output_tokens }
        }

        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true
        http.open_timeout  = 8
        http.read_timeout  = 25
        http.write_timeout = 10

        request = Net::HTTP::Post.new(url)
        request["Content-Type"] = "application/json"
        request.body = body.to_json

        begin
          response = http.request(request)
          result = JSON.parse(response.body)

          unless response.code == "200"
            handle_error(response.code, result)
          end

          response_text = result.dig("candidates", 0, "content", "parts", 0, "text")
          raise AiService::ApiError, "Empty response from Gemini API" if response_text.blank?

          input_tokens = result.dig("usageMetadata", "promptTokenCount") || (prompt.split.size * 1.3).to_i
          output_tokens = result.dig("usageMetadata", "candidatesTokenCount") || (response_text.split.size * 1.3).to_i

          cost = compute_cost(input_tokens, output_tokens, 0.075, 0.3)

          {
            content:             response_text,
            input_tokens:        input_tokens,
            output_tokens:       output_tokens,
            estimated_cost:      cost,
            raw_request:         body,
            raw_response:        result,
            provider_headers:    response.each_header.to_h,
            provider_request_id: response["x-request-id"] || result["id"],
            finish_reason:       result.dig("candidates", 0, "finishReason"),
            http_status:         response.code.to_i
          }
        rescue Net::ReadTimeout, Net::OpenTimeout
          raise AiService::TimeoutError, "Gemini request timed out"
        rescue JSON::ParserError
          raise AiService::ApiError, "Invalid response from Gemini API"
        end
      end

      private

      def handle_error(code, result)
        msg = result.dig("error", "message") || "Gemini API error (HTTP #{code})"
        case code.to_s
        when "400"
          if msg.include?("API key") || msg.include?("key invalid")
            raise AiService::AuthenticationError, msg
          else
            raise AiService::InvalidRequestError, msg
          end
        when "401", "403" then raise AiService::AuthenticationError, msg
        when "429" then raise AiService::RateLimitError, msg
        when "500", "503" then raise AiService::ProviderUnavailableError, msg
        else raise AiService::ApiError, msg
        end
      end
    end
  end
end
