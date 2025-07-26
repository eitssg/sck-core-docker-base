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

# create a vairable with the docker publisher name
$dockerPublisher = "monster-jj.jvj28.com:9092"

# Generate a name of rmy image including the $archType
$packageName = "core-docker-base-$archType"

# Build the Docker image using docker buildx
docker run -it --rm ${dockerPublisher}/${packageName}:latest /bin/bash

