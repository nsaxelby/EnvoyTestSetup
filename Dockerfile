FROM envoyproxy/envoy:dev-af8aef48b5395d32d4bbac5aa3ed0a84d3bf31d1
COPY envoy.yaml /etc/envoy/envoy.yaml
RUN chmod go+r /etc/envoy/envoy.yaml