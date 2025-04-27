# README
# Installation and Setup

To install and run the application locally, follow these steps:

1. **Clone the Repository**  
  Clone the project repository to your local machine using the following command:
  ```bash
  git clone git@github.com:guilhermenunes09/pop-menu-api.git
  cd pop-menu-api
  ```

2. **Install dependencies**
  ```bash
  bundle install
  ```

3. **Setup database**
  ```bash
rails db:create
rails db:migrate
````

4. **Start server**
  ```bash
  rails server
  ```
## API Routes

These are the main routes available in the App. All routes have `/api/v1` as the prefix.

| HTTP Verb | Route                                                                                     | Controller#Action                  | Description                                                                |
|-----------|------------------------------------------------------------------------------------------|------------------------------------|-----------------------------------------------------------------------------|
| POST      | `/api/v1/restaurants/import_json`                                                        | `api/v1/restaurants#import_json`   | Imports restaurant data from a **JSON file.** Supports a force: true param  |
| GET       | `/api/v1/restaurants`                                                                    | `api/v1/restaurants#index`         | Retrieves a list of all restaurants.                                        |
| POST      | `/api/v1/restaurants`                                                                    | `api/v1/restaurants#create`        | Creates a new restaurant.                                                   |
| GET       | `/api/v1/restaurants/:id`                                                                | `api/v1/restaurants#show`          | Retrieves details of a specific restaurant by ID.                           |
| PUT       | `/api/v1/restaurants/:id`                                                                | `api/v1/restaurants#update`        | Updates details of a specific restaurant by ID.                             |
| DELETE    | `/api/v1/restaurants/:id`                                                                | `api/v1/restaurants#destroy`       | Deletes a specific restaurant by ID.                                        |
| GET       | `/api/v1/restaurants/:restaurant_id/menus`                                               | `api/v1/menus#index`               | Retrieves a list of all menus for a specific restaurant.                    |
| POST      | `/api/v1/restaurants/:restaurant_id/menus`                                               | `api/v1/menus#create`              | Creates a new menu for a specific restaurant.                               |
| GET       | `/api/v1/restaurants/:restaurant_id/menus/:id`                                           | `api/v1/menus#show`                | Retrieves details of a specific menu by ID.                                 |
| PUT       | `/api/v1/restaurants/:restaurant_id/menus/:id`                                           | `api/v1/menus#update`              | Updates details of a specific menu by ID.                                   |
| DELETE    | `/api/v1/restaurants/:restaurant_id/menus/:id`                                           | `api/v1/menus#destroy`             | Deletes a specific menu by ID.                                              |
| POST      | `/api/v1/restaurants/:restaurant_id/menus/:id/add_menu_item`                             | `api/v1/menus#add_menu_item`       | Adds a menu item to a specific menu.                                        |
| DELETE    | `/api/v1/restaurants/:restaurant_id/menus/:id/remove_menu_item`                          | `api/v1/menus#remove_menu_item`    | Removes a menu item from a specific menu.                                   |
| GET       | `/api/v1/restaurants/:restaurant_id/menu_items`                                          | `api/v1/menu_items#index`          | Retrieves a list of all menu items for a specific restaurant.               |
| POST      | `/api/v1/restaurants/:restaurant_id/menu_items`                                          | `api/v1/menu_items#create`         | Creates a new menu item for a specific restaurant.                          |
| GET       | `/api/v1/restaurants/:restaurant_id/menu_items/:id`                                      | `api/v1/menu_items#show`           | Retrieves details of a specific menu item by ID.                            |
| PUT       | `/api/v1/restaurants/:restaurant_id/menu_items/:id`                                      | `api/v1/menu_items#update`         | Updates details of a specific menu item by ID.                              |
| DELETE    | `/api/v1/restaurants/:restaurant_id/menu_items/:id`                                      | `api/v1/menu_items#destroy`        | Deletes a specific menu item by ID.                                         |

## Tests

Run Tests
  ```bash
  bundle exec rspec
  ```

## Import JSON Data via API

You can import JSON data into the system by sending a `POST` request to the `/api/v1/restaurants/import_json` endpoint. Below are the steps to do this using `curl`.

```bash
curl -X POST http://localhost:3000/api/v1/restaurants/import_json \
  -F "file=@/path/to/your/restaurant_data.json" \
  -F "force=false"
```

If you omit the `force=true` parameter, the import will execute within a transaction. Any errors will cause the entire operation to roll back.

## Import Data via Rake Task
  If you wish, you can import data via a Rake task by running the following command:
  ```bash
  rake import:json
  ```
The sample file is located under `/db/seeds/restaurant_data.json`

This command will execute a transaction.

If you want to force all data into the database, simply add the `--force` option:

  ```bash
  rake import:json -- --force
  ```
