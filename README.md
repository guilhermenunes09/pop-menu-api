# README

## Decisions Explained
After reading the specifications carefully, I decided to follow up on the task in steps. The first thing was to set up the environment. I decided to keep it simple and use SQLite3 as the database, set up RSpec for testing, and create the application as an API since I wouldn't be using the views.

### First Steps
I created a branch for each main step. First, the configuration. Second, Level 1: Basics, where I set up the `Menu` and `MenuItem` models and created all basic operations and associations, also adding the specs. Third, Level 2, where the Restaurant model was introduced and the specifications required me to make some changes in the associations. For example, the `MenuItem` before belonged to `Menu`, but since items can be added to any `Menu` and they do not repeat in the database, I decided to use a `many-to-many` association and created a join table for that: `menu_item_menu`.

`MenuItem` also belongs to Restaurant for simple readability, since they do indirectly belong to a restaurant through Menu.

### Level 3

Finally, Level 3 was the implementation of the `ImportJson` class, where we can upload a JSON file via an `HTTP` request. Although the overall logic is simple, it added complexity as I was adding logs, errors, and messages for each specific action and behavior.

At last, I also decided to use transactions, so that no data would be saved unless all items are correct in the JSON file. This will avoid confusion when uploading files. But if it's really necessary, the user can use force: true as a parameter to save all valid items and skip invalid ones.

I also added a simple rake task for testing. The file is stored in the seeds folder so it's easy to test if the functionality is working properly.

### Final Considerations
It is a really fun and challenging project. I assumed only `MenuItem` should be unique, since `Restaurant` and `Menu` don't have these constraints in the specifications. Besides the tests, I also tested many operations manually to make sure they don't break easily, although probably there are things that could be improved.

Thanks for your time and opportunity.

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

| HTTP | Route                                                                                     |
|-----------|------------------------------------------------------------------------------------------|
| POST      | `/api/v1/restaurants/import_json`                                                        |
| GET       | `/api/v1/restaurants`                                                                    |
| POST      | `/api/v1/restaurants`                                                                    |
| GET       | `/api/v1/restaurants/:id`                                                                |
| PUT       | `/api/v1/restaurants/:id`                                                                |
| DELETE    | `/api/v1/restaurants/:id`                                                                |
| GET       | `/api/v1/restaurants/:restaurant_id/menus`                                               |
| POST      | `/api/v1/restaurants/:restaurant_id/menus`                                               |
| GET       | `/api/v1/restaurants/:restaurant_id/menus/:id`                                           |
| PUT       | `/api/v1/restaurants/:restaurant_id/menus/:id`                                           |
| DELETE    | `/api/v1/restaurants/:restaurant_id/menus/:id`                                           |
| POST      | `/api/v1/restaurants/:restaurant_id/menus/:id/add_menu_item`                             |
| DELETE    | `/api/v1/restaurants/:restaurant_id/menus/:id/remove_menu_item`                          |
| GET       | `/api/v1/restaurants/:restaurant_id/menu_items`                                          |
| POST      | `/api/v1/restaurants/:restaurant_id/menu_items`                                          |
| GET       | `/api/v1/restaurants/:restaurant_id/menu_items/:id`                                      |
| PUT       | `/api/v1/restaurants/:restaurant_id/menu_items/:id`                                      |
| DELETE    | `/api/v1/restaurants/:restaurant_id/menu_items/:id`                                      |


## Tests

Run Tests
  ```bash
  bundle exec rspec
  ```

## Import JSON Data via API

You can import JSON data into the system by sending a `POST` request to the `/api/v1/restaurants/import_json` endpoint. Below are the steps to do this using `curl`.

```bash
curl -X POST http://localhost:3000/api/v1/restaurants/import_json \
  -F "file=@spec/fixtures/large_restaurant_data.json;type=application/json" \
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
