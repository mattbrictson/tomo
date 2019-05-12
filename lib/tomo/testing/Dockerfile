FROM ubuntu:18.04
WORKDIR /provision
COPY ./tomo_test_ed25519.pub /root/.ssh/authorized_keys
COPY ./ubuntu_setup.sh ./
RUN ./ubuntu_setup.sh
COPY ./custom_setup.sh ./
RUN ./custom_setup.sh
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
