namespace :import do
  desc "Import JSON data into the database using the ImportJson class"
  task json: :environment do
    require_relative '../../lib/import_json'

    force_mode = ARGV.include?("--force")
    ARGV.delete("--force")

    json_file_path = Rails.root.join('db', 'seeds', 'restaurant_data.json')

    unless File.exist?(json_file_path)
      puts "Error: JSON file not found at #{json_file_path}"
      exit
    end

    importer = ImportJson.new(json_file_path)
    result = importer.import(force: force_mode)

    puts "--------- LOGS ---------"
    result[:logs].each { |log| puts log }
    puts ""

    puts "--------- ERRORS ---------"
    result[:errors].each { |error| puts error }
    puts ""

    puts "--------- MESSAGES ---------"
    result[:messages].each { |message| puts message }
  end
end
