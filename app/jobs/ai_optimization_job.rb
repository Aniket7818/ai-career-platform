class AiOptimizationJob < ApplicationJob
  queue_as :default

  def perform(request_id)
    request = AiOptimizationRequest.find(request_id)
    return if request.status == 'cancelled'

    request.update!(status: 'processing')

    begin
      result = AiOptimizationService.optimize(
        request.resume,
        request.action,
        request.payload.symbolize_keys,
        request.request_meta.symbolize_keys
      )
      
      request.update!(status: 'completed', result: result)
    rescue => e
      request.update!(status: 'failed', error_message: e.message)
    end
  end
end
