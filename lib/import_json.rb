require "json"

class ImportJson
  def initialize(file)
    @file = file
    @content = get_file_content(file)
    @errors_collector = []
    @logs = []
    @messages = []
  end

  def import(force: false)
    if force
      import_without_transaction
      @messages << "[Warning] (Forced) There are errors, but valid items have been saved." if @errors_collector.any?
    else
      import_with_transaction
      @messages << "[Success] All data was saved successfully!" if @errors_collector.empty?
    end

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
      @messages  << "[Warning] No data was saved: Please fix the issues and try again."
      raise ActiveRecord::Rollback
    end
  end

  def import_without_transaction
    process_data(force: true)
  end

  def process_data(force:)
    return nil unless is_file_valid(@file)

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
        rescue StandardError => e
          handle_error(
            message: "Menu: Unknown error: #{e.message}",
            log_message: "X Menu #{menu_hash[:name]} from restaurant #{restaurant.name} failed",
            force: force,
            exception: e
          )
        end

        next unless menu.persisted?

        if menu_hash[:menu_items]
          menu_hash[:menu_items].each do |menu_item_hash|
            save_menu_item(name: menu_item_hash[:name], price: menu_item_hash[:price], restaurant_id: restaurant.id, force: force)
          end
        end

        if menu_hash[:dishes]
          menu_hash[:dishes].each do |menu_item_hash|
            save_menu_item(name: menu_item_hash[:name], price: menu_item_hash[:price], restaurant_id: restaurant.id, force: force)
          end
        end
      end
    end
  end

  private

  def handle_error(message:, log_message:, force:, exception:)
    @errors_collector << message
    @logs << log_message

    if force
      nil
    else
      raise exception
    end
  end

  def save_menu_item(name:, price:, restaurant_id:, force:)
    menu_item = MenuItem.new(name:, price:, restaurant_id:)

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

  def is_file_valid(file)
    unless file
      @errors_collector << "No file uploaded"
      return false
    end

    is_valid_json = if file.respond_to?(:content_type)
                      file.content_type == "application/json"
    else
                      file.to_s.downcase.end_with?(".json")
    end

    unless is_valid_json
      @errors_collector << "Invalid file type. Only JSON files are allowed."
      return false
    end

    true
  end

  def get_file_content(file)
    content = if file.respond_to?(:read)
                file.read
    elsif file.is_a?(String)
                File.read(file)
    else
                raise "Invalid file type: #{file.class.name}"
    end

    JSON.parse(content).with_indifferent_access
  end
end
