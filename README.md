
# Nginx Panel CLI

A lightweight Bash script to manage your Nginx “sites-available” and “sites-enabled” directories.  
This tool discovers your Nginx configuration path, lets you test & reload Nginx, list sites, and interactively enable or disable virtual hosts—rolling back on errors.

---

## Table of Contents

1. [Prerequisites](#prerequisites)  
2. [Installation](#installation)  
3. [Usage](#usage)  
4. [Options](#options)  
5. [Examples](#examples)  
6. [How It Works](#how-it-works)  
7. [Contributing](#contributing)  
8. [License](#license)  

---

## Prerequisites

- Linux server with **Nginx** installed and managed via `systemd` (i.e. `systemctl reload nginx`).  
- Standard Nginx directory layout under your main `nginx.conf` directory:
  - `sites-available/`
  - `sites-enabled/`
- Bash shell (tested on Bash 4+).

---

## Installation

1. **Clone** this repository:

   ```bash
   curl -s https://raw.githubusercontent.com/ajmalalkhaledi/nginx-panel/main/install.sh | sudo bash
   ```

2. **Test**:

   ```bash
   nginx-panel
   ```

---

## Usage

```bash
nginx-panel [OPTION] [--silent]
```

Run without arguments to display the help message:

```bash
nginx-panel
```

---

## Options

| Flag                    | Description                                                                      |
|-------------------------|----------------------------------------------------------------------------------|
| `--enable [--silent]`   | Enable a site. Interactive by default; auto-select the first unlinked with `--silent`. |
| `--disable`             | Disable a site. Interactive selection from currently enabled sites.             |
| `--status`              | Show the status of all sites (✓ enabled, × disabled).                            |
| `--list`                | List all files in `sites-available`.                                             |
| `--reload`              | Test and reload Nginx if the configuration passes.                               |
| `--test`                | Test the current Nginx configuration without reloading.                          |

---

## Examples

- **List all available sites**  
  ```bash
  nginx-panel --list
  ```

- **Show enabled/disabled status**  
  ```bash
  nginx-panel --status
  ```

- **Enable a site interactively**  
  ```bash
  nginx-panel --enable
  ```

- **Enable the first unlinked site silently**  
  ```bash
  nginx-panel --enable --silent
  ```

- **Disable a site**  
  ```bash
  nginx-panel --disable
  ```

- **Test Nginx config only**  
  ```bash
  nginx-panel --test
  ```

- **Test, then reload Nginx if OK**  
  ```bash
  nginx-panel --reload
  ```

---

## How It Works

1. **Detects Nginx’s `--conf-path`**  
   Invokes `nginx -V` to extract the `--conf-path` argument.  
2. **Locates your `sites-available` & `sites-enabled` dirs**  
   Assumes they live alongside `nginx.conf` in the same directory.  
3. **Provides helper functions**  
   - `test_nginx()`: runs `nginx -t`  
   - `reload_nginx()`: runs `systemctl reload nginx`  
   - `show_status()`: marks each site ✓ or ×  
   - `list_sites()`: lists available configs  
   - `enable_site()`: symlinks a file from `available` → `enabled`, tests & reloads, rolls back on failure  
   - `disable_site()`: removes symlink, tests & reloads, rolls back on failure  
4. **Interactive menus**  
   Uses Bash read loops to prompt for site numbers; allows safe abort (`x` to exit).  

---

## Contributing

Contributions, bug reports, and feature requests are welcome!  
1. Fork the repository.  
2. Create a new branch: `git checkout -b feature/YourFeature`  
3. Commit your changes & push to your fork.  
4. Open a Pull Request.  

Please adhere to the existing code style and include tests where applicable.

---

## License

This project is licensed under the **MIT License**.  


