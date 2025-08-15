FROM jenkins/agent:latest-jdk17

USER root

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Install OCI CLI
RUN pip3 install --break-system-packages oci-cli


# Install Terraform
ARG TERRAFORM_VERSION=1.9.5
RUN curl -fsSL https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o terraform.zip \
    && unzip terraform.zip \
    && mv terraform /usr/local/bin/ \
    && rm terraform.zip

# Prepare OCI config folder
RUN mkdir -p /home/jenkins/.oci && chown -R jenkins:jenkins /home/jenkins

USER jenkins

WORKDIR /home/jenkins

#ENTRYPOINT ["/usr/local/bin/jenkins-agent"]
