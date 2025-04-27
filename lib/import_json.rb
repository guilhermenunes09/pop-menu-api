require 'json'

class ImportJson
  def initialize(file)
    @file = file
    @content = get_file_content(file)
    @errors_collector = []
    @logs = []
  end

  def save_menu_item(name:, price:, restaurant_id:)
    menu_item = MenuItem.new(name:, price:, restaurant_id:)

    begin
      menu_item.save!
      @logs  << "- - Menu Item #{name} from restaurant: #{restaurant_id} saved successfully!"
    rescue ActiveRecord::RecordInvalid => e
      @errors_collector << "Menu Item #{name}: Validation error - #{e.message}"
      @logs  << "- X ERROR: Menu Item #{name} from restaurant: #{restaurant_id} not saved"
      return
    rescue StandardError => e
      @errors_collector <<  "Menu Item #{name} unknown error: #{e.message}"
      @logs  << "- X ERROR: Menu Item #{name} from restaurant: #{restaurant_id} not saved"
      return
    end
  end

  def import
    @content[:restaurants].each do |restaurant_hash|
      restaurant = Restaurant.new(name: restaurant_hash[:name])

      begin
        restaurant.save!
        @logs  << "Restaurant: #{restaurant.name} saved successfully!"
      rescue ActiveRecord::RecordInvalid => e
        @errors_collector << "Restaurant: Validation error: #{e.message}"
        @logs  << "X Restaurant: #{restaurant.name} not saved"
        next
      rescue StandardError => e
        @errors_collector << "Restaurant: Unknown error: #{e.message}"
        @logs  << "X Restaurant: #{restaurant.name} not saved"
        next
      end

      restaurant_hash[:menus].each do |menu_hash|
        menu = Menu.new(name: menu_hash[:name], restaurant_id: restaurant.id)

        begin
          menu.save!
          @logs  << "- Menu #{menu.name} from restaurant: #{restaurant.name} saved successfully!"
        rescue ActiveRecord::RecordInvalid => e
          @errors_collector << "Menu: Validation failed: #{e.message}"
          @logs  << "X Menu #{menu.name} from restaurant: #{restaurant.name} not saved"
          next
        rescue StandardError => e
          @errors_collector <<  "Menu: Unknown error: #{e.message}"
          @logs  << "X Menu #{menu.name} from restaurant: #{restaurant.name} not saved"
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

    {
      success: @errors_collector.size == 0,
      errors: @errors_collector,
      logs: @logs
    }
  end

  private

  def get_file_content(file)
    content = File.read(file)
    JSON.parse(content).with_indifferent_access
  end
end
