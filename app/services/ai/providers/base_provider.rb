module Ai
  module Providers
    class BaseProvider
      attr_reader :config

      def initialize(config = {})
        @config = config
      end

      # Must return a hash:
      # {
      #   content: "...",
      #   input_tokens: ...,
      #   output_tokens: ...,
      #   estimated_cost: ...
      # }
      def generate(prompt:, model:, temperature:, max_output_tokens:)
        raise NotImplementedError
      end

      protected

      def compute_cost(input_tokens, output_tokens, price_per_m_in, price_per_m_out)
        ((input_tokens.to_f / 1_000_000) * price_per_m_in) + ((output_tokens.to_f / 1_000_000) * price_per_m_out)
      end
    end
  end
end
