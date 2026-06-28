class InvoiceGeneratorService
  def initialize(billing_history, user)
    @billing_history = billing_history
    @user = user
  end

  def generate_pdfs!
    dir = Rails.root.join("storage", "invoices", @user.id.to_s)
    FileUtils.mkdir_p(dir) unless File.directory?(dir)

    invoice_path = generate_invoice(dir)
    receipt_path = generate_receipt(dir)

    @billing_history.update!(
      invoice_pdf_path: invoice_path,
      receipt_pdf_path: receipt_path
    )
  end

  private

  def generate_invoice(dir)
    filename = "invoice_#{@billing_history.invoice_number}.pdf"
    path = dir.join(filename)
    
    Prawn::Document.generate(path) do |pdf|
      pdf.font_size 20
      pdf.text "CareerAI", style: :bold, color: "6D4AFF"
      pdf.move_down 10
      pdf.font_size 24
      pdf.text "TAX INVOICE", style: :bold
      pdf.move_down 20

      pdf.font_size 12
      pdf.text "Invoice Number: #{@billing_history.invoice_number}"
      pdf.text "Invoice Date: #{@billing_history.paid_at.strftime('%b %d, %Y')}"
      pdf.move_down 20

      pdf.text "Billed To:", style: :bold
      pdf.text @user.full_name
      pdf.text @user.email
      pdf.move_down 20

      table_data = [
        ["Description", "Amount"],
        ["CareerAI #{@billing_history.plan_name.titleize} Plan (#{@billing_history.billing_cycle})", "#{@billing_history.currency} #{@billing_history.amount}"]
      ]
      pdf.table(table_data, width: pdf.bounds.width, header: true) do |t|
        t.row(0).font_style = :bold
        t.row(0).background_color = "F1F5F9"
        t.cells.padding = 12
        t.cells.border_color = "E2E8F0"
      end

      pdf.move_down 20
      pdf.text "Total Paid: #{@billing_history.currency} #{@billing_history.amount}", style: :bold, size: 14, align: :right
      pdf.move_down 10
      
      pdf.text "Payment Method: #{@billing_history.payment_provider}"
      pdf.text "Transaction ID: #{@billing_history.payment_id}"
      pdf.text "Order ID: #{@billing_history.order_id}"
      
      pdf.move_down 30
      pdf.text "Thank you for subscribing to CareerAI!", align: :center, color: "64748B"
    end
    
    path.to_s
  end

  def generate_receipt(dir)
    filename = "receipt_#{@billing_history.invoice_number}.pdf"
    path = dir.join(filename)
    
    Prawn::Document.generate(path) do |pdf|
      pdf.font_size 20
      pdf.text "CareerAI", style: :bold, color: "6D4AFF"
      pdf.move_down 10
      pdf.font_size 24
      pdf.text "PAYMENT RECEIPT", style: :bold
      pdf.move_down 20

      pdf.font_size 12
      pdf.text "Receipt for: #{@billing_history.invoice_number}"
      pdf.text "Date: #{@billing_history.paid_at.strftime('%b %d, %Y')}"
      pdf.move_down 20

      pdf.text "Customer:", style: :bold
      pdf.text @user.full_name
      pdf.text @user.email
      pdf.move_down 20

      pdf.text "We have successfully received your payment of #{@billing_history.currency} #{@billing_history.amount} for the CareerAI #{@billing_history.plan_name.titleize} plan."
      pdf.move_down 20
      pdf.text "Transaction ID: #{@billing_history.payment_id}"
      pdf.move_down 30
      pdf.text "Thank you for your business!", align: :center, color: "64748B"
    end
    
    path.to_s
  end
end
