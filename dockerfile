# Use the official Jenkins base image
FROM jenkins/jenkins:lts

# Switch to the root user to install necessary tools or packages
USER root

# Update package lists and install any desired tools (e.g., Docker CLI, Git)
# This example installs Docker CLI to enable Docker-in-Docker functionality
RUN apt-get update && \
    apt-get install -y wget unzip && \
    wget https://releases.hashicorp.com/terraform/1.2.9/terraform_1.2.9_linux_amd64.zip && \
    unzip terraform_1.2.9_linux_amd64.zip && \
    mv terraform /usr/local/bin/ && \
    rm terraform_1.2.9_linux_amd64.zip

# Switch back to the jenkins user
USER jenkins

# Expose the default Jenkins HTTP port and JNLP port for agent communication
EXPOSE 8080
EXPOSE 50000

# Set the entrypoint to the default Jenkins entrypoint script
ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/jenkins.sh"]