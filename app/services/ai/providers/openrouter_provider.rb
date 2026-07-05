require "net/http"
require "json"

module Ai
  module Providers
    class OpenrouterProvider < BaseProvider
      def generate(prompt:, model:, temperature:, max_output_tokens:)
        api_key = @config["api_key"]
        raise AiService::ConfigurationError, "OPENROUTER_API_KEY is missing" if api_key.blank?

        url = URI("https://openrouter.ai/api/v1/chat/completions")
        body = {
          model: model || @config["model"],
          messages: [ { role: "user", content: prompt } ],
          temperature: temperature,
          max_tokens: max_output_tokens
        }

        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true
        http.open_timeout  = 8
        http.read_timeout  = 25
        http.write_timeout = 10

        request = Net::HTTP::Post.new(url)
        request["Content-Type"] = "application/json"
        request["Authorization"] = "Bearer #{api_key}"
        request["HTTP-Referer"] = "https://careerai.com"
        request["X-Title"] = "CareerAI"
        request.body = body.to_json

        begin
          response = http.request(request)
          result = JSON.parse(response.body)

          unless response.code == "200"
            handle_error(response.code, result)
          end

          response_text = result.dig("choices", 0, "message", "content")
          raise AiService::ApiError, "Empty response from OpenRouter API" if response_text.blank?

          input_tokens = result.dig("usage", "prompt_tokens") || (prompt.split.size * 1.3).to_i
          output_tokens = result.dig("usage", "completion_tokens") || (response_text.split.size * 1.3).to_i

          cost = result.dig("usage", "total_cost") || compute_cost(input_tokens, output_tokens, 0.2, 0.2)

          {
            content:             response_text,
            input_tokens:        input_tokens,
            output_tokens:       output_tokens,
            estimated_cost:      cost,
            raw_request:         body,
            raw_response:        result,
            provider_headers:    response.each_header.to_h,
            provider_request_id: response["x-request-id"] || result["id"],
            finish_reason:       result.dig("choices", 0, "finish_reason"),
            http_status:         response.code.to_i
          }
        rescue Net::ReadTimeout, Net::OpenTimeout
          raise AiService::TimeoutError, "OpenRouter request timed out"
        rescue JSON::ParserError
          raise AiService::ApiError, "Invalid response from OpenRouter API"
        end
      end

      private

      def handle_error(code, result)
        msg = result.dig("error", "message") || "OpenRouter API error (HTTP #{code})"
        case code.to_s
        when "401" then raise AiService::AuthenticationError, msg
        when "429" then raise AiService::RateLimitError, msg
        when "400" then raise AiService::InvalidRequestError, msg
        when "500", "502", "503" then raise AiService::ProviderUnavailableError, msg
        else raise AiService::ApiError, msg
        end
      end
    end
  end
end
