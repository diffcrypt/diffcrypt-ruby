# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
namespace :diffcrypt do
  desc 'Initialize credentials for all environments'
  task :init, %i[environments] do |_t, args|
    args.with_defaults(
      environments: 'development,test,staging,production',
    )
    environments = args.environments.split(',')

    environments.each do |environment|
      key_path = Rails.root.join('config', 'credentials', "#{environment}.key")
      file_path = Rails.root.join('config', 'credentials', "#{environment}.yml.enc")
      next if File.exist?(file_path) || File.exist?(key_path)

      # Generate a new key
      key = Diffcrypt::Encryptor.generate_key
      key_dir = File.dirname(key_path)
      Dir.mkdir(key_dir) unless Dir.exist?(key_dir)
      ::File.write(key_path, key)

      # Encrypt default contents
      file = Diffcrypt::File.new(file_path)
      data = {
        'secret_key_base' => SecureRandom.hex(32),
      }
      file.write(key, data)
    end

    # Ensure .key files are always ignored
    gitignore_path = Rails.root.join('.gitignore')
    unless File.read(gitignore_path).include?('config/credentials/*.key')
      ::File.open(gitignore_path, 'a') do |f|
        f.write("\nconfig/credentials/*.key")
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
