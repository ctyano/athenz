FROM tatyano/base:latest
COPY ./assembly/zms/target/athenz-zms-*-bin.tar.gz /opt/athenz
COPY ./assembly/zts/target/athenz-zts-*-bin.tar.gz /opt/athenz
COPY ./assembly/ui/target/athenz-ui-*-bin.tar.gz /opt/athenz
COPY ./assembly/utils/target/athenz-utils-*-bin.tar.gz /opt/athenz

RUN cd /opt/athenz/ && tar xfz athenz-zms*.tar.gz && tar xfz athenz-zts*.tar.gz && tar xfz athenz-ui*.tar.gz && tar xfz athenz-utils*.tar.gz

EXPOSE 9443
EXPOSE 4443
EXPOSE 8443

CMD /opt/athenz/start.sh && tail -f /opt/athenz/athenz-ui-*/logs/ui/ui.out
