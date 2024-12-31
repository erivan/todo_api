# Service Architecture Document: To-Do List Management API

## General Description
The To-Do List Management API is a RESTful service built using Rails 8. It provides create, read, update, and delete (CRUD) operations for managing to-do list items. Each item includes a description, a creation date, and an optional due date. The API ensures authentication via Devise with JWT, caching via Redis, and thorough testing with RSpec.

## Main Components

### Rails API Application
Implements the MVC (Model-View-Controller) architecture:

- **Models**: Represent data and business logic (e.g., Task, User).
- **Controllers**: Handle API requests and responses (e.g., TasksController).
- **Views**: Omitted for APIs; JSON responses handled via controllers.

### Authentication
- **Devise with JWT** for secure token-based user authentication.

### Endpoints

#### User Authentication
- **POST /users**: Register a new user.
- **POST /users/sign_in**: Log in and retrieve JWT token.
- **DELETE /users/sign_out**: Log out and invalidate the token.

#### Task Management
- **GET /tasks**: Retrieve all tasks for the authenticated user.
  - Supports **Ransack** for filtering and (search)[https://activerecord-hackery.github.io/ransack/] parameters:
    - `title`, `description`, `due_date`, `status`, `user_id`, and `user_email`.
- **POST /tasks**: Create a new task.
- **PUT /tasks/:id**: Update an existing task.
- **DELETE /tasks/:id**: Delete a task.

#### User Management
- **GET /users**: Retrieve all users.

### Data Persistence
- **PostgreSQL** is the primary database.
- Tables include:
  - `users`: Stores user credentials and metadata.
  - `tasks`: Stores to-do items linked to users.

### Caching
- **Redis** is used to cache frequently accessed data (e.g., task lists) to improve performance.
- Task data is cached per user and invalidated on updates.

### Testing
- **RSpec** for writing unit, integration, and request tests.
- Test cases cover authentication, CRUD operations, and caching.

## Service Organization

### Database Communication
The application uses Active Record for ORM (Object-Relational Mapping).
- **Relationships**:
  - User has many Tasks.
  - Task belongs to a User.

### Caching Strategy
- **GET /tasks**: Cached responses per user.
- Cache invalidated on `POST`, `PUT`, or `DELETE` operations for tasks.

## Development Instructions

### Prerequisites
Ensure you have the following installed:
- Ruby 3.x
- Rails 8.x
- PostgreSQL
- Redis (Production only)

Set up the following environment variables:
- `DATABASE_URL`: URL for the PostgreSQL database.
- `REDIS_URL`: URL for the Redis instance.
- `DEVISE_JWT_SECRET_KEY`: Secret key for JWT authentication.

### Steps
1. Clone the repository:
   ```bash
   git clone <repository_url>
   cd <repository_directory>
   ```
2. Install dependencies:
   ```bash
   bundle install
   ```
3. Set up the database:
   ```bash
   rails db:create db:migrate db:seed
   ```
4. Run the Rails server:
   ```bash
   rails server
   ```
5. Test the application:
   ```bash
   rspec
   ```

### Required Environment Variables
- `DATABASE_URL`: PostgreSQL connection URL.
- `REDIS_URL`: Redis connection URL.
- `DEVISE_JWT_SECRET_KEY`: Secret key for JWT token signing.

Once the server is running, you can access the API at `http://localhost:3000`. Use tools like curl or Postman to interact with the endpoints.

## CircleCI Deployment Instructions

### Step 1: Set Up CircleCI Configuration File
Add a `.circleci/config.yml` file with the necessary configurations.

### Step 2: Configure Environment Variables in CircleCI
Alternatively, use an environment management agent like Vault to store production environment variables.

### Step 3: Commit and Push Changes
Commit your changes so CircleCI automatically starts the pipeline:
```bash
git add .
git commit -m "Add CircleCI configuration"
git push origin main
```

## Accessing the Application
Once deployed, you can access the API at the specified deployment URL. Use tools like curl or Postman to interact with the endpoints.

## Diagrams

### Architecture Diagram
[Link](https://drive.google.com/file/d/1buOEF24z3jpDlFINVk1dRcHt8zygdHoJ/view?usp=sharing)

### Entity-Relationship (ER) Diagram
[Link](https://dbdiagram.io/d/67743c065406798ef7030eec)

