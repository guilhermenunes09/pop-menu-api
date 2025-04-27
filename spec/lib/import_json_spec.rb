require 'rails_helper'
require_relative '../../lib/import_json'

RSpec.describe ImportJson do
  let(:valid_json_file) { Rails.root.join('spec', 'fixtures', 'valid_restaurant_data.json') }
  let(:invalid_json_file) { Rails.root.join('spec', 'fixtures', 'invalid_restaurant_data.json') }

  describe '#import' do
    context 'with valid JSON data' do
      before do
        allow(File).to receive(:read).with(valid_json_file.to_s).and_return(valid_json_content)
      end

      it 'imports data successfully and logs correct messages' do
        importer = ImportJson.new(valid_json_file)
        result = importer.import

        expect(result[:success]).to be true
        expect(result[:errors]).to be_empty
        expect(result[:logs]).to include(
          "Restaurant: Poppo's Cafe saved successfully!",
          "- Menu lunch from restaurant: Poppo's Cafe saved successfully!",
          "- - Menu Item Burger from restaurant: 1 saved successfully!"
        )
      end
    end

    context 'with invalid JSON data' do
      before do
        allow(File).to receive(:read).with(invalid_json_file.to_s).and_return(invalid_json_content)
      end

      it 'collects errors and logs failure messages' do
        importer = ImportJson.new(invalid_json_file)
        result = importer.import

        expect(result[:success]).to be false
        expect(result[:errors]).to eq([
          "Restaurant: Validation error: Validation failed: Name can't be blank"
        ])
        expect(result[:logs]).to include(
          "X Restaurant:  not saved"
        )
      end
    end
  end

  private

  def valid_json_content
    <<~JSON
      {
        "restaurants": [
          {
            "name": "Poppo's Cafe",
            "menus": [
              {
                "name": "lunch",
                "menu_items": [
                  { "name": "Burger", "price": 9.00 }
                ]
              }
            ]
          }
        ]
      }
    JSON
  end

  def invalid_json_content
    <<~JSON
      {
        "restaurants": [
          {
            "name": "",
            "menus": [
              {
                "name": "",
                "menu_items": [
                  { "name": "", "price": null }
                ]
              }
            ]
          }
        ]
      }
    JSON
  end
end
