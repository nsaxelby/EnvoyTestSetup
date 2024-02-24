package com.envoytest.services.kafkaanalytics;

import com.amazonaws.services.kinesisanalytics.runtime.KinesisAnalyticsRuntime;
import com.esotericsoftware.minlog.Log;

import org.apache.flink.api.common.eventtime.WatermarkStrategy;
import org.apache.flink.api.common.serialization.SimpleStringSchema;
import org.apache.flink.connector.base.DeliveryGuarantee;
import org.apache.flink.connector.kafka.sink.KafkaRecordSerializationSchema;
import org.apache.flink.connector.kafka.sink.KafkaSink;
import org.apache.flink.connector.kafka.source.KafkaSource;
import org.apache.flink.connector.kafka.source.enumerator.initializer.OffsetsInitializer;
import org.apache.flink.streaming.api.datastream.DataStream;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;

import java.io.IOException;
import java.util.Properties;

public class BasicStreamingJob {

        private static DataStream<String> createKafkaSourceFromApplicationProperties(
                        StreamExecutionEnvironment env) throws IOException {
                Properties sourceProperties = KinesisAnalyticsRuntime.getApplicationProperties()
                                .get("KafkaSource");
                Log.info("KafkaSource bootstrap servers: {}",
                                (String) sourceProperties.get("bootstrap.servers"));
                Log.info("KafkaSource topic {}}", (String) sourceProperties.get("topic"));

                KafkaSource<String> source = KafkaSource.<String>builder()
                                .setBootstrapServers(
                                                (String) sourceProperties.get("bootstrap.servers"))
                                .setTopics((String) sourceProperties.get("topic"))
                                .setGroupId("kafka-replication")
                                .setStartingOffsets(OffsetsInitializer.latest())
                                .setValueOnlyDeserializer(new SimpleStringSchema())
                                .setProperty("security.protocol", "SASL_SSL")
                                .setProperty("sasl.mechanism", "SCRAM-SHA-512")
                                // Set JAAS configurations
                                // TODO hard coded username and password for now, don't do this in
                                // prod
                                .setProperty("sasl.jaas.config",
                                                "org.apache.kafka.common.security.scram.ScramLoginModule required username=\"my-user\" password=\"supersecrets\";")
                                .build();

                return env.fromSource(source, WatermarkStrategy.noWatermarks(), "Kafka Source");
        }

        private static KafkaSink<String> createKafkaSinkFromApplicationProperties()
                        throws IOException {
                Properties sinkProperties =
                                KinesisAnalyticsRuntime.getApplicationProperties().get("KafkaSink");

                Log.info("KafkaSink bootstrap servers: {}",
                                (String) sinkProperties.get("bootstrap.servers"));
                Log.info("KafkaSink topic {}}", (String) sinkProperties.get("topic"));

                Properties kafkaProducerConfig = new Properties();
                kafkaProducerConfig.setProperty("security.protocol", "SASL_SSL");
                kafkaProducerConfig.setProperty("sasl.mechanism", "SCRAM-SHA-512");
                // kafkaProducerConfig.setProperty("transactional.id", "transact1");
                // kafkaProducerConfig.setProperty("client.id.prefix", "blahh234");
                kafkaProducerConfig.setProperty("transaction.timeout.ms", "1000");
                // kafkaProducerConfig.setProperty("transaction.max.timeout.ms", "1000");
                // TODO hard coded username and password for now, don't do this in prod

                kafkaProducerConfig.setProperty("sasl.jaas.config",
                                "org.apache.kafka.common.security.scram.ScramLoginModule required username=\"my-user\" password=\"supersecrets\";");

                return KafkaSink.<String>builder()
                                .setBootstrapServers(
                                                sinkProperties.getProperty("bootstrap.servers"))
                                .setRecordSerializer(KafkaRecordSerializationSchema.builder()
                                                .setTopic((String) sinkProperties.get("topic"))
                                                .setKeySerializationSchema(new SimpleStringSchema())
                                                .setValueSerializationSchema(
                                                                new SimpleStringSchema())
                                                .build())
                                .setKafkaProducerConfig(kafkaProducerConfig)
                                .setDeliverGuarantee(DeliveryGuarantee.NONE).build();
        }

        public static void main(String[] args) throws Exception {
                // set up the streaming execution environment
                final StreamExecutionEnvironment env =
                                StreamExecutionEnvironment.getExecutionEnvironment();

                DataStream<String> input = createKafkaSourceFromApplicationProperties(env);

                // Add sink
                input.sinkTo(createKafkaSinkFromApplicationProperties());

                env.execute("Flink Streaming Java API Skeleton");
        }
}
