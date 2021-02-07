FROM ghcr.io/hfuss/constellation:latest

COPY --from=ghcr.io/hfuss/quorum:latest /usr/local/bin/bootnode /usr/local/bin/
COPY --from=ghcr.io/hfuss/quorum:latest /usr/local/bin/geth /usr/local/bin/
ENTRYPOINT ["/bin/bash"]
