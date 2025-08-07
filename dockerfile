# Use the official Jenkins base image
FROM jenkins/jenkins:lts

# Switch to the root user to install necessary tools or packages
USER root

# Update package lists and install any desired tools (e.g., Docker CLI, Git)
# This example installs Docker CLI to enable Docker-in-Docker functionality
RUN apt-get update && \
    apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && \
    apt-get install -y docker-ce-cli

# Switch back to the jenkins user
USER jenkins

# Expose the default Jenkins HTTP port and JNLP port for agent communication
EXPOSE 8080
EXPOSE 50000

# Set the entrypoint to the default Jenkins entrypoint script
ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/jenkins.sh"]