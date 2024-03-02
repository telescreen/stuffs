FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y lsb-release wget software-properties-common gnupg ninja-build cmake
COPY llvm.sh .
RUN chmod +x llvm.sh && ./llvm.sh 17

