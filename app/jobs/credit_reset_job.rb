class CreditResetJob < ApplicationJob
  queue_as :default

  def perform
    CreditResetService.process_all!
  end
end
