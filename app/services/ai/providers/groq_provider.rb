require "net/http"
require "json"

module Ai
  module Providers
    class GroqProvider < BaseProvider
      ENDPOINT = "https://api.groq.com/openai/v1/chat/completions"
      # Llama-3.3-70b pricing: $0.59 / $0.79 per 1M tokens
      PRICE_IN  = 0.59
      PRICE_OUT = 0.79

      def generate(prompt:, model:, temperature:, max_output_tokens:)
        api_key = @config["api_key"]

        if api_key.blank?
          Rails.logger.error "[GroqProvider] CONFIGURATION ERROR: GROQ_API_KEY is missing or blank"
          raise AiService::ConfigurationError, "GROQ_API_KEY is missing"
        end

        resolved_model = model || @config["model"] || "llama-3.3-70b-versatile"
        Rails.logger.info "[GroqProvider] PREPARING request model=#{resolved_model} prompt_chars=#{prompt.length}"

        url  = URI(ENDPOINT)
        body = {
          model:       resolved_model,
          messages:    [ { role: "user", content: prompt } ],
          temperature: temperature,
          max_tokens:  max_output_tokens
        }

        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl      = true
        http.open_timeout = 8   # TCP connect
        http.read_timeout = 25  # response read — fires inside 30s Timeout::timeout
        http.write_timeout = 10 # request send

        request = Net::HTTP::Post.new(url)
        request["Content-Type"]  = "application/json"
        request["Authorization"] = "Bearer #{api_key}"
        request.body = body.to_json

        Rails.logger.info "[GroqProvider] SENDING HTTP request to #{ENDPOINT}"

        begin
          response = http.request(request)
          Rails.logger.info "[GroqProvider] HTTP RESPONSE received status=#{response.code}"

          result = JSON.parse(response.body)

          unless response.code == "200"
            Rails.logger.error "[GroqProvider] API ERROR status=#{response.code} body=#{response.body.first(300)}"
            handle_error(response.code, result)
          end

          response_text = result.dig("choices", 0, "message", "content")

          if response_text.blank?
            Rails.logger.error "[GroqProvider] EMPTY RESPONSE body=#{response.body.first(300)}"
            raise AiService::ApiError, "Empty response from Groq API"
          end

          input_tokens  = result.dig("usage", "prompt_tokens")     || (prompt.split.size * 1.3).to_i
          output_tokens = result.dig("usage", "completion_tokens") || (response_text.split.size * 1.3).to_i
          cost          = compute_cost(input_tokens, output_tokens, PRICE_IN, PRICE_OUT)

          Rails.logger.info "[GroqProvider] SUCCESS tokens_in=#{input_tokens} tokens_out=#{output_tokens} cost=$#{cost.round(6)}"

          {
            content:        response_text,
            input_tokens:   input_tokens,
            output_tokens:  output_tokens,
            estimated_cost: cost
          }

        rescue Net::ReadTimeout, Net::OpenTimeout => e
          Rails.logger.error "[GroqProvider] TIMEOUT #{e.class}: #{e.message}"
          raise AiService::TimeoutError, "Groq request timed out (#{e.class})"
        rescue JSON::ParserError => e
          Rails.logger.error "[GroqProvider] JSON PARSE ERROR: #{e.message}"
          raise AiService::ApiError, "Invalid JSON response from Groq API"
        end
      end

      private

      def handle_error(code, result)
        msg = result.dig("error", "message") || "Groq API error (HTTP #{code})"
        case code.to_s
        when "401"        then raise AiService::AuthenticationError,      msg
        when "429"        then raise AiService::RateLimitError,            msg
        when "400"        then raise AiService::InvalidRequestError,       msg
        when "500", "502",
             "503"        then raise AiService::ProviderUnavailableError,  msg
        else                   raise AiService::ApiError,                  msg
        end
      end
    end
  end
end
