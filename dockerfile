FROM jenkins/jenkins:lts

USER root

# Install Docker CLI dependencies
RUN apt-get update && apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    openssh-client \
    git \
    unzip \
    wget

# Add Docker official GPG key
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add Docker repo to apt sources
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker CLI only (not the daemon)
RUN apt-get update && apt-get install -y docker-ce-cli

# Install Terraform (latest stable)
RUN curl -fsSL https://releases.hashicorp.com/terraform/1.2.9/terraform_1.2.9_linux_amd64.zip -o terraform.zip \
 && unzip terraform.zip \
 && mv terraform /usr/local/bin/terraform \
 && rm terraform.zip


# Copy your private key file into the config_test2 directory inside the container
COPY config_test2/ayadifatma418@gmail.com-2025-07-10T13_34_58.521Z.pem /var/jenkins_home/workspace/terraform_deploy/config_test2/

# Set permissions for the private key
RUN chmod 600 /var/jenkins_home/workspace/terraform_deploy/config_test2/ayadifatma418@gmail.com-2025-07-10T13_34_58.521Z.pem

# Clean up apt cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

USER jenkins
