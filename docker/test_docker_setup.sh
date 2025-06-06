#!/bin/bash

# test_docker_setup.sh
# A utility script to verify Docker setup for AiExec in both development and deployment environments.

# Color codes for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Keep track of tests passed and failed
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_WARNINGS=0

# Minimum requirements
MIN_MEMORY_GB=4
MIN_DISK_GB=10
MIN_DOCKER_VERSION="20.10.0"
MIN_COMPOSE_VERSION="2.0.0"

# Array of required ports to check
REQUIRED_PORTS=(80 443 3000 5001 5002 5003 6379 8080 8194)

echo -e "${BLUE}=========================================================${NC}"
echo -e "${BLUE}      AiExec Docker Environment Validation Tool          ${NC}"
echo -e "${BLUE}=========================================================${NC}"
echo

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to compare versions
version_greater_equal() {
    printf '%s\n%s\n' "$2" "$1" | sort -V -C
}

# Function to log test results
log_test() {
    local test_name="$1"
    local status="$2"
    local message="$3"
    
    if [ "$status" == "PASS" ]; then
        echo -e "${GREEN}✓ PASS${NC}: $test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    elif [ "$status" == "WARN" ]; then
        echo -e "${YELLOW}⚠ WARNING${NC}: $test_name"
        echo -e "  ${YELLOW}$message${NC}"
        TESTS_WARNINGS=$((TESTS_WARNINGS + 1))
    else
        echo -e "${RED}✗ FAIL${NC}: $test_name"
        echo -e "  ${RED}$message${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

# Function to convert string to bytes
to_bytes() {
    local value=$1
    local unit=${value//[0-9.]/}
    local number=${value//[^0-9.]/}
    
    case "$unit" in
        K|KB) echo $(echo "$number * 1024" | bc) ;;
        M|MB) echo $(echo "$number * 1024 * 1024" | bc) ;;
        G|GB) echo $(echo "$number * 1024 * 1024 * 1024" | bc) ;;
        T|TB) echo $(echo "$number * 1024 * 1024 * 1024 * 1024" | bc) ;;
        *) echo "$number" ;;
    esac
}

# Section: Docker Installation Check
echo -e "${BLUE}[1/6] Checking Docker Installation${NC}"

if command_exists docker; then
    docker_version=$(docker version --format '{{.Server.Version}}' 2>/dev/null)
    if [ $? -ne 0 ]; then
        log_test "Docker daemon running" "FAIL" "Docker daemon is not running. Start Docker and try again."
    elif version_greater_equal "$docker_version" "$MIN_DOCKER_VERSION"; then
        log_test "Docker version ($docker_version)" "PASS"
    else
        log_test "Docker version ($docker_version)" "WARN" "Docker version $docker_version is below recommended version $MIN_DOCKER_VERSION"
    fi
else
    log_test "Docker installation" "FAIL" "Docker is not installed. Please install Docker before continuing."
fi

if command_exists docker-compose; then
    compose_version=$(docker-compose version --short 2>/dev/null)
    if version_greater_equal "$compose_version" "$MIN_COMPOSE_VERSION"; then
        log_test "Docker Compose version ($compose_version)" "PASS"
    else
        log_test "Docker Compose version ($compose_version)" "WARN" "Docker Compose version $compose_version is below recommended version $MIN_COMPOSE_VERSION"
    fi
elif command_exists docker && docker compose version >/dev/null 2>&1; then
    compose_version=$(docker compose version --short 2>/dev/null)
    if version_greater_equal "$compose_version" "$MIN_COMPOSE_VERSION"; then
        log_test "Docker Compose plugin ($compose_version)" "PASS"
    else
        log_test "Docker Compose plugin ($compose_version)" "WARN" "Docker Compose plugin version $compose_version is below recommended version $MIN_COMPOSE_VERSION"
    fi
else
    log_test "Docker Compose" "FAIL" "Docker Compose is not installed. Please install Docker Compose before continuing."
fi

# Section: System Requirements
echo
echo -e "${BLUE}[2/6] Checking System Requirements${NC}"

# Check memory
if command_exists free; then
    # Linux
    total_memory_kb=$(free -t --kilo | grep "Total:" | awk '{print $2}')
    total_memory_gb=$(echo "scale=1; $total_memory_kb/1024/1024" | bc)
elif command_exists sysctl; then
    # macOS
    total_memory_bytes=$(sysctl -n hw.memsize 2>/dev/null)
    total_memory_gb=$(echo "scale=1; $total_memory_bytes/1024/1024/1024" | bc)
else
    total_memory_gb="unknown"
fi

if [ "$total_memory_gb" != "unknown" ]; then
    if (( $(echo "$total_memory_gb >= $MIN_MEMORY_GB" | bc -l) )); then
        log_test "System memory (${total_memory_gb}GB)" "PASS"
    else
        log_test "System memory (${total_memory_gb}GB)" "WARN" "Less than recommended ${MIN_MEMORY_GB}GB of RAM. Performance may be affected."
    fi
else
    log_test "System memory" "WARN" "Could not determine system memory. Ensure you have at least ${MIN_MEMORY_GB}GB of RAM."
fi

# Check disk space
if command_exists df; then
    disk_available_kb=$(df -k . | tail -1 | awk '{print $4}')
    disk_available_gb=$(echo "scale=1; $disk_available_kb/1024/1024" | bc)
    
    if (( $(echo "$disk_available_gb >= $MIN_DISK_GB" | bc -l) )); then
        log_test "Available disk space (${disk_available_gb}GB)" "PASS"
    else
        log_test "Available disk space (${disk_available_gb}GB)" "WARN" "Less than recommended ${MIN_DISK_GB}GB of free disk space. Performance may be affected."
    fi
else
    log_test "Disk space" "WARN" "Could not determine available disk space. Ensure you have at least ${MIN_DISK_GB}GB free."
fi

# Check Docker resources (if on Docker Desktop)
if command_exists docker && docker info >/dev/null 2>&1; then
    if docker info 2>/dev/null | grep -i "docker desktop" >/dev/null; then
        # Docker Desktop detected
        docker_memory=$(docker info 2>/dev/null | grep "Total Memory" | awk '{print $3$4}')
        docker_memory_bytes=$(to_bytes "$docker_memory")
        docker_memory_gb=$(echo "scale=1; $docker_memory_bytes/1024/1024/1024" | bc)
        
        if (( $(echo "$docker_memory_gb >= $MIN_MEMORY_GB" | bc -l) )); then
            log_test "Docker Desktop memory allocation (${docker_memory_gb}GB)" "PASS"
        else
            log_test "Docker Desktop memory allocation (${docker_memory_gb}GB)" "WARN" "Docker Desktop has less than ${MIN_MEMORY_GB}GB of memory allocated. Increase in Docker Desktop settings."
        fi
    fi
fi

# Section: Port Availability
echo
echo -e "${BLUE}[3/6] Checking Port Availability${NC}"

for port in "${REQUIRED_PORTS[@]}"; do
    # Different methods for different platforms
    if command_exists nc; then
        nc -z localhost "$port" >/dev/null 2>&1
        port_status=$?
    elif command_exists netstat; then
        netstat -an | grep "LISTEN" | grep ":$port " >/dev/null 2>&1
        port_status=$?
    elif command_exists lsof; then
        lsof -i ":$port" | grep "LISTEN" >/dev/null 2>&1
        port_status=$?
    else
        port_status=1  # Assume port is available if can't check
    fi
    
    if [ $port_status -eq 0 ]; then
        log_test "Port $port" "WARN" "Port $port is already in use. This may conflict with AiExec services."
    else
        log_test "Port $port" "PASS"
    fi
done

# Section: Environment Files
echo
echo -e "${BLUE}[4/6] Validating Environment Files${NC}"

# Check for .env.example files
if [ -f "./deploy/.env.example" ]; then
    log_test "Deployment .env.example file" "PASS"
else
    log_test "Deployment .env.example file" "FAIL" "Missing ./deploy/.env.example file. Clone the repository again or download it."
fi

if [ -f "./dev/dev.env.example" ]; then
    log_test "Development .env.example file" "PASS"
else
    log_test "Development .env.example file" "WARN" "Missing ./dev/dev.env.example file. Development environment may not configure properly."
fi

# Check for actual .env files
if [ -f "./deploy/.env" ]; then
    log_test "Deployment .env file" "PASS"
else
    log_test "Deployment .env file" "WARN" "Missing ./deploy/.env file. Run 'cp ./deploy/.env.example ./deploy/.env' to create it."
fi

if [ -f "./dev/dev.env" ]; then
    log_test "Development .env file" "PASS"
else
    log_test "Development .env file" "WARN" "Missing ./dev/dev.env file. Run 'cp ./dev/dev.env.example ./dev/dev.env' to create it."
fi

# Validate critical environment variables if .env files exist
if [ -f "./deploy/.env" ]; then
    secret_key=$(grep "^SECRET_KEY=" "./deploy/.env" | cut -d '=' -f2)
    if [ -z "$secret_key" ] || [ "$secret_key" = "sk-9f73s3ljTXVcMT3Blb3ljTqtsKiGHXVcMT3BlbkFJLK7U" ]; then
        log_test "SECRET_KEY security" "WARN" "Using default SECRET_KEY in production is insecure. Generate a new key with 'openssl rand -base64 42'."
    else
        log_test "SECRET_KEY security" "PASS"
    fi
    
    db_password=$(grep "^DB_PASSWORD=" "./deploy/.env" | cut -d '=' -f2)
    if [ -z "$db_password" ] || [ "$db_password" = "aiexecai123456" ]; then
        log_test "DB_PASSWORD security" "WARN" "Using default database password in production is insecure. Set a strong password."
    else
        log_test "DB_PASSWORD security" "PASS"
    fi
fi

# Section: Docker Connectivity Test
echo
echo -e "${BLUE}[5/6] Testing Docker Connectivity${NC}"

# Check if Docker can pull images
if command_exists docker; then
    echo "Testing Docker Hub connectivity by pulling a small test image..."
    if docker pull hello-world:latest >/dev/null 2>&1; then
        log_test "Docker Hub connectivity" "PASS"
    else
        log_test "Docker Hub connectivity" "FAIL" "Cannot pull images from Docker Hub. Check your internet connection and Docker configuration."
    fi
else
    log_test "Docker Hub connectivity" "FAIL" "Docker is not available for testing connectivity."
fi

# Check Docker network
if command_exists docker; then
    if docker network ls | grep -q "bridge"; then
        log_test "Docker default network" "PASS"
    else
        log_test "Docker default network" "WARN" "Default bridge network not found. Docker may not be configured correctly."
    fi
fi

# Section: Summary and Suggestions
echo
echo -e "${BLUE}[6/6] Summary and Suggestions${NC}"

echo -e "Tests run: $(($TESTS_PASSED + $TESTS_FAILED + $TESTS_WARNINGS))"
echo -e "${GREEN}Tests passed: $TESTS_PASSED${NC}"
echo -e "${YELLOW}Warnings: $TESTS_WARNINGS${NC}"
echo -e "${RED}Tests failed: $TESTS_FAILED${NC}"
echo

if [ $TESTS_FAILED -eq 0 ] && [ $TESTS_WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✓ All tests passed! Your system is ready for running AiExec with Docker.${NC}"
    echo
    echo -e "To start the application:"
    echo -e "  • For production: cd docker/deploy && docker-compose up -d"
    echo -e "  • For development: cd docker/dev && ./dev.start.sh"
elif [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${YELLOW}⚠ Your system can run AiExec with Docker, but there are some warnings to address.${NC}"
    echo
    echo -e "Suggestions:"
    echo -e "  • Create environment files if missing"
    echo -e "  • Set secure passwords in .env files"
    echo -e "  • Check for port conflicts and resolve them"
    echo -e "  • Consider increasing Docker Desktop resource allocation if applicable"
else
    echo -e "${RED}✗ Your system needs additional configuration before running AiExec with Docker.${NC}"
    echo
    echo -e "Required actions:"
    echo -e "  • Install Docker and Docker Compose if missing"
    echo -e "  • Ensure Docker daemon is running"
    echo -e "  • Fix port conflicts"
    echo -e "  • Ensure environment files are properly set up"
fi

echo
echo -e "For more information, refer to the documentation:"
echo -e "  • Production deployment: docker/deploy/README.md"
echo -e "  • Development environment: docker/dev/README.md"
echo

exit $TESTS_FAILED

