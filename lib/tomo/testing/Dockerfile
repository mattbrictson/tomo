FROM ubuntu:22.04
WORKDIR /provision
COPY ./tomo_test_ed25519.pub /root/.ssh/authorized_keys
COPY ./ubuntu_setup.sh ./
RUN ./ubuntu_setup.sh
COPY ./systemctl.rb /usr/local/bin/systemctl
RUN chmod a+x /usr/local/bin/systemctl
EXPOSE 22
EXPOSE 3000
CMD ["/usr/sbin/sshd", "-D"]
