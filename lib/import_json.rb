require "json"

class ImportJson
  def initialize(file)
    @errors_collector = []
    @logs = []
    @messages = []
    @file = file
    @content = parse_file_content(file)
  end

  def import(force: false)
    return error_result("No valid file content") unless @content

    if force
      import_without_transaction
      @messages << "[Warning] (Forced) There are errors, but valid items have been saved." if @errors_collector.any?
    else
      import_with_transaction
    end

    @messages << "[Success] All data was saved successfully!" if @errors_collector.empty?

    {
      messages: @messages,
      success: @errors_collector.empty?,
      errors: @errors_collector,
      logs: @logs
    }
  end

  def import_with_transaction
    ActiveRecord::Base.transaction do
      process_data(force: false)
    rescue StandardError => e
      @errors_collector << "Transaction failed: #{e.message}"
      @messages << "[Warning] No data was saved: Please fix the issues and try again."
      raise ActiveRecord::Rollback
    end
  end

  def import_without_transaction
    process_data(force: true)
  end


  private

  def process_data(force:)
    @content[:restaurants].each do |restaurant_hash|
      restaurant = Restaurant.new(name: restaurant_hash[:name])

      begin
        restaurant.save!
        @logs << "Restaurant: #{restaurant_hash[:name]} saved successfully!"
      rescue ActiveRecord::RecordInvalid => e
        handle_error(
          message: "Restaurant: Validation error: #{e.message}",
          log_message: "X Restaurant: #{restaurant_hash[:name]} not saved",
          force: force,
          exception: e
        )
      rescue StandardError => e
        handle_error(
          message: "Restaurant: Unknown error: #{e.message}",
          log_message: "X Restaurant: #{restaurant_hash[:name]} not saved",
          force: force,
          exception: e
        )
      end

      next unless restaurant.persisted?

      restaurant_hash[:menus].each do |menu_hash|
        process_menu(menu_hash, restaurant, force)
      end
    end
  end

  def process_menu(menu_hash, restaurant, force)
    menu = Menu.new(name: menu_hash[:name], restaurant_id: restaurant.id)

    begin
      menu.save!
      @logs << "- Menu #{menu_hash[:name]} from restaurant #{restaurant.name} ok"
    rescue ActiveRecord::RecordInvalid => e
      handle_error(
        message: "Menu: Validation failed: #{e.message}",
        log_message: "X Menu #{menu_hash[:name]} from restaurant #{restaurant.name} failed",
        force: force,
        exception: e
      )
      return
    rescue StandardError => e
      handle_error(
        message: "Menu: Unknown error: #{e.message}",
        log_message: "X Menu #{menu_hash[:name]} from restaurant #{restaurant.name} failed",
        force: force,
        exception: e
      )
      return
    end

    process_menu_items(menu_hash[:menu_items], restaurant.id, force) if menu_hash[:menu_items]
    process_menu_items(menu_hash[:dishes], restaurant.id, force) if menu_hash[:dishes]
  end

  def process_menu_items(items, restaurant_id, force)
    items.each do |item_hash|
      save_menu_item(
        name: item_hash[:name],
        price: item_hash[:price],
        restaurant_id: restaurant_id,
        force: force
      )
    end
  end

  def save_menu_item(name:, price:, restaurant_id:, force:)
    menu_item = MenuItem.new(name: name, price: price, restaurant_id: restaurant_id)

    begin
      menu_item.save!
      @logs << "- - Menu Item #{name} from restaurant #{restaurant_id} ok"
    rescue ActiveRecord::RecordInvalid => e
      handle_error(
        message: "Menu Item #{name}: Validation error - #{e.message}",
        log_message: "- X ERROR: Menu Item #{name} from restaurant #{restaurant_id} failed",
        force: force,
        exception: e
      )
    rescue StandardError => e
      handle_error(
        message: "Menu Item #{name} unknown error: #{e.message}",
        log_message: "- X ERROR: Menu Item #{name} from restaurant #{restaurant_id} failed",
        force: force,
        exception: e
      )
    end
  end

  def parse_file_content(file)
    if file.respond_to?(:content_type)
      return unless file.content_type == "application/json"
    end

    content = if file.respond_to?(:read)
                file.read
              elsif file.is_a?(String) && File.exist?(file)
                File.read(file)
              else
                raise ArgumentError, "Invalid file: must be an IO object or valid file path"
              end

    parsed_content = JSON.parse(content, symbolize_names: true)

    unless parsed_content.is_a?(Hash) && parsed_content.key?(:restaurants)
      @errors_collector << "Invalid file structure: Expected a hash with a :restaurants key"
      return nil
    end

    parsed_content
  end

  def handle_error(message:, log_message:, force:, exception:)
    @errors_collector << message
    @logs << log_message
    raise exception unless force
  end

  def error_result(message)
    @errors_collector << message
    {
      messages: [],
      success: false,
      errors: @errors_collector,
      logs: []
    }
  end
end
