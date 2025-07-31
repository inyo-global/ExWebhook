# ExWebhook

ExWebhook transforms messages from a Broadway producer (Kafka, SQS, Google Pub/Sub, etc.) into webhooks.

## Features
- Tenant Aware: Each webhook is tied to a `tenantId`, and every message should have a `tenantId` field to determine which webhook to call.
- Batch messages in a single webhook call: as JSONLine webhooks (optional).

## Running
The easiest way to get started with ExWebhook is by using Docker. There's a SQS Docker Compose example in the sample/sqs directory using LocalStack.

## Sample Configuration
The runtime.exs file is configured as:

### Batch Processor

```
config :webhook, :batch_processor_options,
  producer_module: BroadwaySQS.Producer,
  producer_options: [
    queue_url: "http://localstack:4566/000000000000/sqs-batch",
    config: [
      scheme: "http://",
      host: "localstack",
      port: 4566,
      access_key_id: "",
      secret_access_key: ""
    ]
  ],
  batch_size: 3,
  batch_timeout: 3_000
```

### Single Processor

```
config :webhook, :single_processor_options,
  producer_module: BroadwaySQS.Producer,
  producer_options: [
    queue_url: "http://localstack:4566/000000000000/sqs-single",
    config: [
      scheme: "http://",
      host: "localstack",
      port: 4566,
      access_key_id: "",
      secret_access_key: ""
    ]
  ]
```

## Execution
Just start the docker using `docker compose up`and execute the `run.sh` script, which emits messages and executes the webhook. You can check the webhook call status using the database.

-----

## For Local Development

### Prerequisites

Before you begin, make sure you have the following tools installed on your machine:

  * **Elixir and Erlang/OTP:** This project requires a specific version of Elixir and Erlang/OTP. The minimum compatible Elixir version is usually indicated in the project's `mix.exs` file (look for `elixir: "~> x.y"`).

      * **Verify installation:**
        ```bash
        elixir --version
        erl -eval 'erlang:display(erlang:system_info(otp_release)).' -s init stop
        ```
      * **Installation (if necessary):** The most recommended way to install Elixir and Erlang is via `asdf` (version manager), `Homebrew` (macOS), `apt` (Debian/Ubuntu), or `choco` (Windows). For more details, consult the [official Elixir documentation](https://elixir-lang.org/install.html).

  * **CMake and Make (for NIFs or dependencies with C code):** Some Elixir/Erlang libraries (NIFs - Native Implemented Functions) depend on C/C++ code and require build tools like **CMake** and **Make**.

      * **Verify installation:**
        ```bash
        cmake --version
        make --version
        ```
      * **Installation (if necessary):**
          * **macOS:** `brew install cmake`
          * **Linux (Debian/Ubuntu):** `sudo apt install cmake build-essential`
          * **Windows:** Download the official installer from [CMake](https://cmake.org/download/) (make sure to add it to your PATH) and install [MinGW](https://www.google.com/search?q=http://mingw-w64.org/doku.php/download) or configure [WSL with build tools](https://learn.microsoft.com/en-us/windows/wsl/install).

### Configuration

1.  **Clone the repository:**

    ```bash
    git clone https://github.com/inyo-global/ExWebhook
    cd [PROJECT_FOLDER_NAME]
    ```

2.  **Install Elixir dependencies:**
    Navigate to the project's root directory and install all Hex dependencies:

    ```bash
    mix deps.get
    ```

3.  **Run Database Migration:**
    After configuring the database credentials, run the migrations:

    ```bash
    mix ecto.migrate
    ```

### Compilation

Navigate to the project's root directory and compile with the command:

```bash
mix compile
```

### Running Tests

To run the project's tests:

```bash
mix test
```

-----

## Common Troubleshooting

  * **`mix: command not found`**: Verify that Elixir and Erlang/OTP are correctly installed and that the Elixir binary directory is in your `PATH`.
  * **`make: cmake: No such file or directory`**: Install **CMake** and **Make** as per the prerequisites section.
  * **Dependency errors (`Hex dependency resolution failed`)**: Run `mix deps.clean --all` and then try `mix deps.get` again. Check if there are no explicit dependencies in your `mix.exs` that might conflict with those required by other libraries.
