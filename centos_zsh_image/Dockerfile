FROM centos:8
RUN dnf install -y zsh && \
    dnf clean all
RUN curl -o /root/.zshrc https://raw.githubusercontent.com/cradle8810/zshrc/master/zshrc
WORKDIR /root
ENTRYPOINT ["zsh"]