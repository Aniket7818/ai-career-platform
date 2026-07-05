module Ai
  module Providers
    class StubProvider < BaseProvider
      def generate(prompt:, model:, temperature:, max_output_tokens:)
        Rails.logger.warn "[StubProvider] Simulating AI response for development"

        {
          content: "[STUB] This is a simulated AI response for development. Configure an AI provider to enable real AI generation.",
          input_tokens: 50,
          output_tokens: 30,
          estimated_cost: 0.0,
          raw_request: { model: model, messages: [{ role: "user", content: prompt }] },
          raw_response: { choices: [{ message: { content: "[STUB]..." } }] },
          provider_headers: { "x-stub-header" => "stub-value" },
          provider_request_id: "stub-req-12345",
          finish_reason: "stop",
          http_status: 200
        }
      end
    end
  end
end
