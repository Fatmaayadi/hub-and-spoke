FROM jenkins/jenkins:lts

USER root

# Install dependencies
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

# Add Docker GPG key & repo
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker CLI
RUN apt-get update && apt-get install -y docker-ce-cli

# Install Terraform v1.2.9
RUN curl -fsSL https://releases.hashicorp.com/terraform/1.2.9/terraform_1.2.9_linux_amd64.zip -o terraform.zip \
 && unzip terraform.zip \
 && mv terraform /usr/local/bin/terraform \
 && rm terraform.zip

# ✅ Copy OCI private key to /root/.oci/oci_api_key.pem (required by provider)
RUN mkdir -p /root/.oci/
COPY config_test2/ayadifatma418@gmail.com-2025-07-10T13_34_58.521Z.pem /root/.oci/oci_api_key.pem
RUN chmod 600 /root/.oci/oci_api_key.pem

# Clean up
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

USER jenkins
