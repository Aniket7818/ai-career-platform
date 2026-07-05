class ResumePdfService
  def initialize(resume_id, cookie_header = nil)
    @resume_id = resume_id
    @cookie_header = cookie_header
  end

  def generate_pdf
    require "ferrum"

    # The frontend URL for the print view
    frontend_url = ENV.fetch("FRONTEND_URL", "http://localhost:5173")
    target_url = "#{frontend_url}/resumes/#{@resume_id}/print"

    # Start Ferrum browser
    browser = Ferrum::Browser.new(
      headless: true,
      window_size: [ 1024, 768 ],
      browser_options: {
        'no-sandbox': nil,
        'disable-setuid-sandbox': nil,
        'disable-dev-shm-usage': nil
      }
    )

    # Force the browser to send the user's session cookie for all requests
    browser.headers.add({ "Cookie" => @cookie_header }) if @cookie_header

    # Navigate to the print route and wait for network to be idle
    browser.goto(target_url)
    browser.network.wait_for_idle(timeout: 10)

    # CRITICAL: Wait for fonts to finish loading
    browser.evaluate_async(%(
      var callback = arguments[arguments.length - 1];
      document.fonts.ready.then(function() { callback(true); });
    ), 5)

    # Wait an extra second just in case Vue is still mounting components
    sleep 1

    pdf_buffer = browser.pdf(
      encoding: :binary,
      format: :A4,
      print_background: true,
      margin_top: 0,
      margin_bottom: 0,
      margin_left: 0,
      margin_right: 0
    )

    browser.quit
    pdf_buffer
  end
end
