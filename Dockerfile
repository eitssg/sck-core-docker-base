# Define the build argument
ARG ARCH

FROM ubuntu:latest AS os

# Set environment variables
ENV PYTHONUNBUFFERED=1

# Install dependencies
RUN apt-get update && \
    apt-get install -y python3 python3-pip python3-venv unzip curl \
    less groff jq wget lsb-release software-properties-common \
    ca-certificates apt-transport-https nginx

    # Install the gitlab-runner
RUN curl -s -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh" | bash

# Install additional dependencies for gitlab-runner
RUN apt-get update && apt-get install -y gitlab-runner nodejs npm

# Install Terraform
RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add - && \
    add-apt-repository "deb [arch=$ARCH] https://apt.releases.hashicorp.com $(lsb_release -cs) main" && \
    apt-get update && \
    apt-get install -y terraform

# Clean APT System
RUN apt-get clean

# Install AWS CLI 2.0 x86 or aarch64
ARG ARCH
RUN if [ "$ARCH" = "amd64" ]; then \
        ARCH1="x86_64"; \
    elif [ "$ARCH" = "arm64" ]; then \
        ARCH1="aarch64"; \
    else \
        echo "Unsupported architecture: $ARCH"; exit 1; \
    fi && \
    curl -s "https://awscli.amazonaws.com/awscli-exe-linux-${ARCH1}.zip" -o "awscliv2.zip" && \
    unzip -qq awscliv2.zip && \
    ./aws/install && \
    rm -rf awscliv2.zip aws

# Install the aws CDK
RUN npm install -g aws-cdk

# Create a new user called "core" with UID 1002 and a home directory
RUN useradd -m -u 1002 core

# Switch to the new user
USER core

# Set the home directory
WORKDIR /home/core

# Specify the default shell
SHELL ["/bin/bash", "-c"]

# Create a virtual environment in a hidden folder
RUN python3 -m venv /home/core/.venv

ARG NEXUS_SERVER
ARG PIP_INDEX_URL

# Point PIP to our local Nexus server
ENV NEXUS_SERVER=$NEXUS_SERVER
ENV PIP_INDEX_URL=$PIP_INDEX_URL

# Activate the virtual environment and install Poetry
RUN source /home/core/.venv/bin/activate && \
    python -m pip install --upgrade pip && \
    pip install poetry poetry-dynamic-versioning polib

# Install the Python aws CDK module
RUN source /home/core/.venv/bin/activate && pip install aws-cdk-core constructs

# Ensure the virtual environment is activated for the core user
RUN echo "source /home/core/.venv/bin/activate" >> /home/core/.bashrc
RUN echo "export NEXUS_SERVER=${NEXUS_SERVER}" >> /home/core/.bashrc

# Tell PIP to pull from the mirror $NEXUS_SERVER/repository/pypi/simple
RUN echo "export PIP_INDEX_URL=${PIP_INDEX_URL}" >> /home/core/.bashrc

# Set the entrypoint to activate the virtual environment
ENTRYPOINT ["/bin/bash", "-c", "source /home/core/.venv/bin/activate && exec \"$@\"", "--"]

# Set the default command to run when the container starts
CMD ["bash"]