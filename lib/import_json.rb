require "json"

class ImportJson
  def initialize(file)
    @file = file
    @content = get_file_content(file)
    @errors_collector = []
    @logs = []
  end

  def import
    return nil unless is_file_valid(@file)

    @content[:restaurants].each do |restaurant_hash|
      restaurant = Restaurant.new(name: restaurant_hash[:name])

      begin
        restaurant.save!
        @logs << "Restaurant: #{restaurant_hash[:name]} saved successfully!"
      rescue ActiveRecord::RecordInvalid => e
        @errors_collector << "Restaurant: Validation error: #{e.message}"
        @logs << "X Restaurant: #{restaurant_hash[:name]} not saved"
        next
      rescue StandardError => e
        @errors_collector << "Restaurant: Unknown error: #{e.message}"
        @logs << "X Restaurant: #{restaurant_hash[:name]} not saved"
        next
      end

      restaurant_hash[:menus].each do |menu_hash|
        menu = Menu.new(name: menu_hash[:name], restaurant_id: restaurant.id)

        begin
          menu.save!
          @logs << "- Menu #{menu_hash[:name]} from restaurant: #{restaurant.name} saved successfully!"
        rescue ActiveRecord::RecordInvalid => e
          @errors_collector << "Menu: Validation failed: #{e.message}"
          @logs << "X Menu #{menu_hash[:name]} from restaurant: #{restaurant.name} not saved"
          next
        rescue StandardError => e
          @errors_collector <<  "Menu: Unknown error: #{e.message}"
          @logs << "X Menu #{menu_hash[:name]} from restaurant: #{restaurant.name} not saved"
          next
        end

        if menu_hash[:menu_items]
          menu_hash[:menu_items].each do |menu_item_hash|
            save_menu_item(name: menu_item_hash[:name], price: menu_item_hash[:price], restaurant_id: restaurant.id)
          end
        end

        if menu_hash[:dishes]
          menu_hash[:dishes].each do |menu_item_hash|
            save_menu_item(name: menu_item_hash[:name], price: menu_item_hash[:price], restaurant_id: restaurant.id)
          end
        end
      end
    end

    result(@errors_collector, @logs)
  end

  private

  def result(errors, logs)
    {
      success: errors.size == 0,
      errors: errors,
      logs: logs
    }
  end

  def save_menu_item(name:, price:, restaurant_id:)
    menu_item = MenuItem.new(name:, price:, restaurant_id:)

    begin
      menu_item.save!
      @logs << "- - Menu Item #{name} from restaurant: #{restaurant_id} saved successfully!"
    rescue ActiveRecord::RecordInvalid => e
      @errors_collector << "Menu Item #{name}: Validation error - #{e.message}"
      @logs << "- X ERROR: Menu Item #{name} from restaurant: #{restaurant_id} not saved"
      nil
    rescue StandardError => e
      @errors_collector <<  "Menu Item #{name} unknown error: #{e.message}"
      @logs << "- X ERROR: Menu Item #{name} from restaurant: #{restaurant_id} not saved"
      nil
    end
  end

  def is_file_valid(file)
    unless file
      @errors_collector << "No file uploaded"
      result(@errors_collector, @logs)
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
