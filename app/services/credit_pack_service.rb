class CreditPackService
  PACKS = {
    pack_100: { credits: 100, price_rupees: 99, label: "100 AI Credits Pack" },
    pack_300: { credits: 300, price_rupees: 249, label: "300 AI Credits Pack" },
    pack_1000: { credits: 1000, price_rupees: 699, label: "1000 AI Credits Pack" }
  }.with_indifferent_access.freeze

  def self.purchase!(user, pack_id, payment_id = nil)
    pack = PACKS[pack_id]
    raise ArgumentError, "Unknown credit pack: #{pack_id}" if pack.nil?

    ActiveRecord::Base.transaction do
      # Add credits to user balance
      CreditService.add_credits!(
        user,
        pack[:credits],
        feature_name: "Purchased #{pack[:label]}",
        reference_id: payment_id
      )

      # Create billing history for auditing and invoice generations
      user.billing_histories.create!(
        plan_name: pack[:label],
        amount: pack[:price_rupees],
        currency: "INR",
        payment_provider: "Razorpay",
        payment_id: payment_id || "manual_pack_#{SecureRandom.hex(6)}",
        invoice_number: "INV-PACK-#{Time.current.year}-#{SecureRandom.hex(3).upcase}",
        billing_cycle: "one_time",
        payment_status: "Paid",
        paid_at: Time.current
      )
    end
  end
end
