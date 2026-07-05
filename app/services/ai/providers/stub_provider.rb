module Ai
  module Providers
    class StubProvider < BaseProvider
      def generate(prompt:, model:, temperature:, max_output_tokens:)
        Rails.logger.warn "[StubProvider] Simulating AI response for development"

        {
          content: "[STUB] This is a simulated AI response for development. Configure an AI provider to enable real AI generation.",
          input_tokens: 50,
          output_tokens: 30,
          estimated_cost: 0.0
        }
      end
    end
  end
end
