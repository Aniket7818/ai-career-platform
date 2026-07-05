class PromptLibrary
  class PromptNotFoundError < StandardError; end

  def self.load(feature, version, context = {})
    file_path = Rails.root.join("config", "prompts", "#{feature}_#{version}.txt.erb")
    raise PromptNotFoundError, "Prompt '#{feature}' version '#{version}' not found" unless File.exist?(file_path)

    template = File.read(file_path)

    # Render using a simple string-interpolation approach:
    # Replace <%= key %> with the value, and process <% if/unless/end %> blocks.
    # This avoids all ERB binding/scope issues with Ruby 3.3+
    render(template, context.transform_keys(&:to_s))

  rescue PromptNotFoundError
    raise
  rescue => e
    raise PromptNotFoundError, "Prompt template error in '#{feature}': #{e.message}"
  end

  def self.render(template, vars)
    result = template.dup

    # Process conditional blocks first: <% if expr %>...<% end %>
    # We evaluate by checking truthiness of the var value
    result = result.gsub(/<% if (\w+)\.present\? && \w+ != ["'][^"']*["'] %>(.*?)<% end %>/m) do |match|
      var_name = $1
      content  = $2
      val = vars[var_name].to_s
      (val.present? && val != "None") ? content : ""
    end

    result = result.gsub(/<% if (\w+)\.present\? %>(.*?)<% end %>/m) do |match|
      var_name = $1
      content  = $2
      vars[var_name].to_s.present? ? content : ""
    end

    result = result.gsub(/<% if (\w+) %>(.*?)<% end %>/m) do |match|
      var_name = $1
      content  = $2
      vars[var_name].to_s.present? ? content : ""
    end

    # Then replace <%= key %> with the value
    result = result.gsub(/<%=\s*(\w+)\s*%>/) do |match|
      vars[$1].to_s
    end

    # Clean up any remaining ERB tags
    result = result.gsub(/<%-?\s*[^%]*-?%>/, "")

    result
  end
end
