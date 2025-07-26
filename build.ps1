# Get the processor architecture
$architecture = (Get-WmiObject -Class Win32_Processor).Architecture

# Determine if the CPU is ARM or x86
switch ($architecture) {
    0 { $archType = "amd64" }
    1 { $archType = "mips64" }
    2 { $archType = "Alpha Unsupported" }
    3 { $archType = "ppc64le" }
    5 { $archType = "arm64" }
    6 { $archType = "Itanium-based systems Unsupported" }
    9 { $archType = "amd64" }
    default { $archType = "Unknown" }
}

# Print a message indicating the architecture of the machine
Write-Host "Building CORE Base Docker image for architecture: $archType"

# Create and use a new builder instance
docker buildx create --use

# create a vairable with the docker publisher name
$dockerPublisher = "monster-jj.jvj28.com:9092"

# Log in using environment variables
$env:NEXUS_PASSWORD | docker login $dockerPublisher `
    --username $env:NEXUS_USERNAME --password-stdin

# Generate a name of rmy image including the $archType
$packageName = "core-docker-base-$archType"

# Build the Docker image using docker buildx
docker buildx build `
   --platform linux/$archType `
   --build-arg ARCH=$archType `
   --build-arg NEXUS_SERVER=$env:NEXUS_SERVER `
   --build-arg PIP_INDEX_URL=$env:PIP_INDEX_URL `
   -t ${dockerPublisher}/${packageName}:latest `
   --push .

# Print a message indicating the build is complete
Write-Host "Docker image '${packageName}:latest' built successfully."
