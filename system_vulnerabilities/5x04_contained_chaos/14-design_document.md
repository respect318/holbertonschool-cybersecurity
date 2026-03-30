# Secure Python Development Environment Design

## 1. Base Image Selection
- **Image:** `python:3.11-slim`
- **Reasoning:**  
  - Slim image minimizes attack surface.  
  - Includes Python 3.11, up-to-date runtime.  
  - Smaller image size reduces unnecessary packages and vulnerabilities.  

## 2. Included Tools
- **Linters:** `pylint`, `flake8`  
- **Formatters:** `black`, `isort`  
- **Testing:** `pytest`, `coverage`  
- **Dependency Management:** `pip-tools`  
- **Security Tools:** `bandit` (static analysis for security issues)  
- **Reasoning:** Ensures code quality, security, and test coverage in development environment.

## 3. User Configuration
- **Non-Root User:** `devuser`  
  - UID/GID set to 1000 (common convention)  
  - Home directory `/home/devuser`  
  - Bash as default shell  
- **Reasoning:** Principle of least privilege; prevents accidental root execution and container compromise.

## 4. Volume Strategy
- **Mount Source Code:**  
  ```bash
  docker run -v /host/path/project:/app
