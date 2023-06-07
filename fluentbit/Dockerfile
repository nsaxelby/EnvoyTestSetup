FROM public.ecr.aws/aws-observability/aws-for-fluent-bit:stable
ADD myconf.conf /
CMD ["/fluent-bit/bin/fluent-bit", "-e", "/fluent-bit/firehose.so", "-e", "/fluent-bit/cloudwatch.so", "-e", "/fluent-bit/kinesis.so", "-c", "/myconf.conf"]
