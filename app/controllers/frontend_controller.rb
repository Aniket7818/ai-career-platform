class FrontendController < ActionController::Base
  def show
    if Rails.env.development?
      frontend_url = ENV.fetch("FRONTEND_URL", "http://localhost:5173").delete_suffix("/")
      redirect_to "#{frontend_url}#{request.fullpath}", allow_other_host: true
      return
    end

    index_path = Rails.root.join("public", "frontend", "index.html")
    return render file: index_path, layout: false if File.exist?(index_path)

    render plain: "Frontend build not found. Run npm run build and copy frontend/dist to public/frontend.", status: :not_found
  end
end
