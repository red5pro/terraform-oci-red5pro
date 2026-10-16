#!/bin/bash
######################################
# Install and configure Kafka Server
######################################
# KAFKA_CLUSTER_ID="kafka-id"

set -euo pipefail

CURRENT_DIRECTORY=$(pwd)
packages=(ca-certificates curl)

export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_SUSPEND=1

log_i() {
    log
    printf "\033[0;32m [INFO]  --- %s \033[0m\n" "${@}"
}
log_w() {
    log
    printf "\033[0;35m [WARN] --- %s \033[0m\n" "${@}"
}
log_e() {
    log
    printf "\033[0;31m [ERROR]  --- %s \033[0m\n" "${@}"
}
log() {
    echo -n "[$(date '+%Y-%m-%d %H:%M:%S')]"
}

install_pkg() {
    for i in {1..5}; do
        local install_issue=0
        apt-get -y update --fix-missing || true

        for index in ${!packages[*]}; do
            log_i "Install utility ${packages[$index]}"
            apt-get install -y ${packages[$index]} || true
        done

        for index in ${!packages[*]}; do
            local PKG_OK
            PKG_OK=$(dpkg-query -W --showformat='${Status}\n' ${packages[$index]} | grep "install ok installed" || true)
            if [ -z "$PKG_OK" ]; then
                log_i "${packages[$index]} utility didn't install, didn't find MIRROR !!! "
                install_issue=$((install_issue + 1))
            else
                log_i "${packages[$index]} utility installed"
            fi
        done

        if [ ${install_issue} -eq 0 ]; then
            break
        fi
        if [ $i -ge 5 ]; then
            log_e "Something wrong with packages installation!!! Exit."
            exit 1
        fi
        sleep 20
    done
}

install_docker() {
    log_i "Install Docker"

    # Add Docker's official GPG key:
    install -m 0755 -d /etc/apt/keyrings
    curl -4fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    chmod a+r /etc/apt/keyrings/docker.asc

    # Add the repository to Apt sources:
    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
        | tee /etc/apt/sources.list.d/docker.list >/dev/null
        tee /etc/apt/sources.list.d/docker.list >/dev/null

    # Install Docker
    packages=(docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin)
    install_pkg

    systemctl enable --now docker

    # Add user to the docker group
    usermod -aG docker ubuntu
}

check_memory_requirements() {
    local total_memory_mb
    total_memory_mb=$(free -m | awk '/^Mem:/{print $2}') # Value in MB

    if [ "$total_memory_mb" -lt 8192 ]; then
        log_e "Kafka requires at least 8 GB of memory. Found ${total_memory_mb} MB. Exiting."
        exit 1
    fi
}

force_apt_ipv4() {
    log_i "Forcing apt to use IPv4 (avoids slow/failed IPv6 attempts to Ubuntu mirrors on networks without IPv6 routing)"
    echo 'Acquire::ForceIPv4 "true";' >/etc/apt/apt.conf.d/99force-ipv4
}

wait_for_dns() {
    log_i "Waiting for DNS resolution to become available"
    local timeout=90
    local elapsed=0
    while ! getent hosts archive.ubuntu.com &>/dev/null; do
        if [ "$elapsed" -ge "$timeout" ]; then
            log_w "DNS still not resolving after ${timeout}s, proceeding anyway"
            break
        fi
        sleep 2
        elapsed=$((elapsed + 2))
    done
    log_i "DNS resolution check finished after ${elapsed}s"
}

start_kafka() {
    log_i "Start Kafka Docker container"

    cd "$CURRENT_DIRECTORY"

    if [[ ! -f ".env" ]]; then
        log_e "Kafka .env file does not exist"
        exit 1
    fi

    if ! docker compose -f docker-compose.embedded-kafka.yml config --quiet; then
        log_e "Invalid Kafka Docker Compose configuration"
        exit 1
    fi

    if ! docker compose -f docker-compose.embedded-kafka.yml up -d --no-deps kafka0; then
        log_e "Kafka Docker container failed to start"
        exit 1
    fi

    log_i "Waiting for Kafka broker to become healthy"

    for i in {1..60}; do
        status=$(docker inspect --format '{{.State.Status}}' kafka0 2>/dev/null || true)
        health=$(docker inspect --format '{{if .State.Health}}{{.State.Health.Status}}{{else}}none{{end}}' kafka0 2>/dev/null || true)

        if [[ "$status" == "running" && "$health" == "healthy" ]]; then
            log_i "Kafka broker is healthy"
            return 0
        fi

        if [[ "$status" == "exited" || "$status" == "restarting" ]]; then
            log_w "Kafka container status: $status"
        fi

        sleep 10
    done

    log_e "Kafka broker did not become healthy within 600 seconds"
    docker logs --tail 100 kafka0 || true
    exit 1
}

check_memory_requirements

# Use Google DNS instead of the OCI VCN resolver, which can be slow or
# unresponsive right after boot and stall apt/curl for several minutes.
log_i "Modify DNS servers in systemd-resolved"
echo "DNS=8.8.8.8 8.8.4.4" >>/etc/systemd/resolved.conf
echo "FallbackDNS=2001:4860:4860::8888 2001:4860:4860::8844" >>/etc/systemd/resolved.conf
systemctl restart systemd-resolved

wait_for_dns
force_apt_ipv4
install_pkg
install_docker
start_kafka
