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
        result = importer.import(force: false)

        expect(result[:success]).to be true
        expect(result[:errors]).to be_empty
        expect(result[:logs]).to include(
          "Restaurant: Poppo's Cafe saved successfully!",
          "- Menu lunch from restaurant Poppo's Cafe ok",
          "- - Menu Item Burger from restaurant 1 ok"
        )
        expect(result[:messages]).to include("[Success] All data was saved successfully!")
      end
    end

    context 'with invalid JSON data' do
      before do
        allow(File).to receive(:read).with(invalid_json_file.to_s).and_return(invalid_json_content)
      end

      context 'when force mode is disabled' do
        it 'rolls back the transaction and logs failure messages' do
          importer = ImportJson.new(invalid_json_file)
          result = importer.import(force: false)

          expect(result[:success]).to be false
          expect(result[:errors]).to include("Restaurant: Validation error: Validation failed: Name can't be blank")
          expect(result[:logs]).to include("X Restaurant:  not saved")
          expect(result[:messages]).to include("[Warning] No data was saved: Please fix the issues and try again.")
        end
      end

      context 'when force mode is enabled' do
        it 'saves valid items and logs warnings for invalid items' do
          allow(File).to receive(:read).with(invalid_json_file.to_s).and_return(mixed_json_content)

          importer = ImportJson.new(invalid_json_file)
          result = importer.import(force: true)

          expect(result[:success]).to be false
          expect(result[:errors]).to include("Restaurant: Validation error: Validation failed: Name can't be blank")
          expect(result[:logs]).to include(
            "Restaurant: Valid Restaurant saved successfully!",
            "X Restaurant:  not saved"
          )
          expect(result[:messages]).to include("[Warning] (Forced) There are errors, but valid items have been saved.")
        end
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

  def mixed_json_content
    <<~JSON
      {
        "restaurants": [
          {
            "name": "Valid Restaurant",
            "menus": []
          },
          {
            "name": "",
            "menus": []
          }
        ]
      }
    JSON
  end
end
