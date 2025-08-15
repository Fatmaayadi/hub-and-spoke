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
ARG TERRAFORM_VERSION=1.2.9
RUN curl -fsSL https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o terraform.zip \
    && unzip terraform.zip \
    && mv terraform /usr/local/bin/ \
    && rm terraform.zip

# Prepare OCI config folder
RUN mkdir -p /home/jenkins/.oci && chown -R jenkins:jenkins /home/jenkins

# Copy OCI config and agent.jar
#COPY --chown=jenkins:jenkins oci_config /home/jenkins/.oci
COPY --chown=jenkins:jenkins agent.jar /home/jenkins/agent/agent.jar

USER jenkins
WORKDIR /home/jenkins

# Start the agent automatically
CMD ["java", "-jar", "/home/jenkins/agent/agent.jar","-url", "http://jenkins:8080/","-secret", "0e7aa5617b92f576ad59da70dcb3afccb5529653bb2c03fcdf0cfbc3df48e68f","-name", "oci-agent","-webSocket","-workDir", "/home/jenkins/agent"]