# Copilot Instructions (Submodule: sck-core-docker-base)

## Plan → Approval → Execute (Mandatory)
Any base image layer, dependency pin, or build arg modification requires prior plan & approval.

- Tech: Docker base images.
- Precedence: Local first; then root `../../.github/...`.
- Conventions: Favor slim, pinned images and multi-stage builds. Avoid leaking secrets into layers.

## Contradiction Detection
- Validate against minimal/pinned image guidance.
- If conflict, warn + options + example.
- Example: "Embedding credentials in build args conflicts with security rules; use build-time secrets or CI vault."

## Standalone clone note
If cloned standalone, see:
- Root Copilot guidance: https://github.com/eitssg/simple-cloud-kit/blob/develop/.github/copilot-instructions.md
 
