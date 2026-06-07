module EnvLoader
  module_function

  def load!(root_path)
    env_file = File.join(root_path, ".env")
    return unless File.exist?(env_file)

    File.readlines(env_file).each do |line|
      next if line.strip.empty? || line.lstrip.start_with?("#")

      key, value = line.strip.split("=", 2)
      next if key.nil? || key.empty? || value.nil? || ENV.key?(key)

      ENV[key] = value.gsub(/\A['"]|['"]\z/, "")
    end
  end
end
