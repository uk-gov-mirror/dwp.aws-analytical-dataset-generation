---
Configurations:
- Classification: "yarn-site"
  Properties:
    "yarn.log-aggregation-enable": "true"
    "yarn.nodemanager.remote-app-log-dir": "s3://${s3_log_bucket}/${s3_log_prefix}/yarn"
    "yarn.nodemanager.vmem-check-enabled": "false"
    "yarn.nodemanager.pmem-check-enabled": "false"
    "yarn.acl.enable": "true"
    "yarn.resourcemanager.scheduler.monitor.enable": "true"
    "yarn.resourcemanager.scheduler.class": "org.apache.hadoop.yarn.server.resourcemanager.scheduler.capacity.CapacityScheduler"

- Classification: "spark"
  Properties:
    "maximizeResourceAllocation": "false"

- Classification: "capacity-scheduler"
  Properties:
    "yarn.scheduler.capacity.root.queues": "default,appqueue1,appqueue2,mrqueue"
    "yarn.scheduler.capacity.maximum-am-resource-percent": "0.9"
    "yarn.scheduler.capacity.resource-calculator": "org.apache.hadoop.yarn.util.resource.DominantResourceCalculator"
    "yarn.scheduler.capacity.root.default.capacity": "5"
    "yarn.scheduler.capacity.root.default.maximum-capacity": "10"
    "yarn.scheduler.capacity.root.default.acl_submit_applications": ""
    "yarn.scheduler.capacity.root.appqueue1.capacity": "15"
    "yarn.scheduler.capacity.root.appqueue1.acl_submit_applications": "*"
    "yarn.scheduler.capacity.root.appqueue1.maximum-capacity": "90"
    "yarn.scheduler.capacity.root.appqueue1.state": "RUNNING"
    "yarn.scheduler.capacity.root.appqueue1.ordering-policy": "fair"
    "yarn.scheduler.capacity.root.appqueue1.ordering-policy.fair.enable-size-based-weight": "true"
    "yarn.scheduler.capacity.root.appqueue1.default-application-priority": "1"
    "yarn.scheduler.capacity.root.appqueue2.capacity": "15"
    "yarn.scheduler.capacity.root.appqueue2.acl_submit_applications": "*"
    "yarn.scheduler.capacity.root.appqueue2.maximum-capacity": "90"
    "yarn.scheduler.capacity.root.appqueue2.state": "RUNNING"
    "yarn.scheduler.capacity.root.appqueue2.ordering-policy": "fair"
    "yarn.scheduler.capacity.root.appqueue2.ordering-policy.fair.enable-size-based-weight": "true"
    "yarn.scheduler.capacity.root.appqueue2.default-application-priority": "1"
    "yarn.scheduler.capacity.root.mrqueue.ordering-policy.fair.enable-size-based-weight": "true"
    "yarn.scheduler.capacity.root.mrqueue.capacity": "65"
    "yarn.scheduler.capacity.root.mrqueue.acl_submit_applications": "*"
    "yarn.scheduler.capacity.root.mrqueue.maximum-capacity": "90"
    "yarn.scheduler.capacity.root.mrqueue.state": "RUNNING"
    "yarn.scheduler.capacity.root.mrqueue.ordering-policy": "fair"
    "yarn.scheduler.capacity.root.mrqueue.ordering-policy.fair.enable-size-based-weight": "true"
    "yarn.scheduler.capacity.root.mrqueue.default-application-priority": "2"

- Classification: "spark-defaults"
  Properties:
    "spark.yarn.jars": "/usr/lib/spark/jars/*,/opt/emr/metrics/dependencies/*"
    "spark.sql.catalogImplementation": "hive"
    "spark.yarn.dist.files": "/etc/spark/conf/hive-site.xml,/etc/pki/tls/private/private_key.key,/etc/pki/tls/certs/private_key.crt,/etc/pki/ca-trust/source/anchors/analytical_ca.pem"
    "spark.executor.extraClassPath": "/usr/lib/hadoop-lzo/lib/*:/usr/lib/hadoop/hadoop-aws.jar:/usr/share/aws/aws-java-sdk/*:/usr/share/aws/emr/emrfs/conf:/usr/share/aws/emr/emrfs/lib/*:/usr/share/aws/emr/emrfs/auxlib/*:/usr/share/aws/emr/goodies/lib/emr-spark-goodies.jar:/usr/share/aws/emr/security/conf:/usr/share/aws/emr/security/lib/*:/usr/share/aws/hmclient/lib/aws-glue-datacatalog-spark-client.jar:/usr/share/java/Hive-JSON-Serde/hive-openx-serde.jar:/usr/share/aws/sagemaker-spark-sdk/lib/sagemaker-spark-sdk.jar:/usr/share/aws/emr/s3select/lib/emr-s3-select-spark-connector.jar:/opt/emr/metrics/dependencies/*"
    "spark.driver.extraClassPath": "/usr/lib/hadoop-lzo/lib/*:/usr/lib/hadoop/hadoop-aws.jar:/usr/share/aws/aws-java-sdk/*:/usr/share/aws/emr/emrfs/conf:/usr/share/aws/emr/emrfs/lib/*:/usr/share/aws/emr/emrfs/auxlib/*:/usr/share/aws/emr/goodies/lib/emr-spark-goodies.jar:/usr/share/aws/emr/security/conf:/usr/share/aws/emr/security/lib/*:/usr/share/aws/hmclient/lib/aws-glue-datacatalog-spark-client.jar:/usr/share/java/Hive-JSON-Serde/hive-openx-serde.jar:/usr/share/aws/sagemaker-spark-sdk/lib/sagemaker-spark-sdk.jar:/usr/share/aws/emr/s3select/lib/emr-s3-select-spark-connector.jar:/opt/emr/metrics/dependencies/*"
    "spark.executor.defaultJavaOptions": "-XX:+UseG1GC -XX:+UnlockDiagnosticVMOptions -XX:+G1SummarizeConcMark -XX:InitiatingHeapOccupancyPercent=35 -verbose:gc -XX:+PrintGCDetails -XX:+PrintGCDateStamps -XX:OnOutOfMemoryError='kill -9 %p' -Dhttp.proxyHost='${proxy_http_host}' -Dhttp.proxyPort='${proxy_http_port}' -Dhttp.nonProxyHosts='${proxy_no_proxy}' -Dhttps.proxyHost='${proxy_https_host}' -Dhttps.proxyPort='${proxy_https_port}'"
    "spark.driver.defaultJavaOptions": "-XX:+UseG1GC -XX:+UnlockDiagnosticVMOptions -XX:+G1SummarizeConcMark -XX:InitiatingHeapOccupancyPercent=35 -verbose:gc -XX:+PrintGCDetails -XX:+PrintGCDateStamps -XX:OnOutOfMemoryError='kill -9 %p' -Dhttp.proxyHost='${proxy_http_host}' -Dhttp.proxyPort='${proxy_http_port}' -Dhttp.nonProxyHosts='${proxy_no_proxy}' -Dhttps.proxyHost='${proxy_https_host}' -Dhttps.proxyPort='${proxy_https_port}'"
    "spark.sql.warehouse.dir": "s3://${s3_published_bucket}/analytical-dataset/hive/external"
    "spark.serializer": "org.apache.spark.serializer.KryoSerializer"
    "spark.kryoserializer.buffer.max": "${spark_kyro_buffer}"
    "spark.driver.maxResultSize": "0"
    "spark.dynamicAllocation.enabled": "false"
    "spark.executor.cores": "${spark_executor_cores}"
    "spark.executor.memory": "${spark_executor_memory}G"
    "spark.executor.memoryOverhead": "${spark_yarn_executor_memory_overhead}G"
    "spark.driver.memory": "${spark_driver_memory}G"
    "spark.driver.cores": "${spark_driver_cores}"
    "spark.executor.instances": "${spark_executor_instances}"
    "spark.default.parallelism": "${spark_default_parallelism}"
    "spark.yarn.queue": "appqueue1"

- Classification: "spark-hive-site"
  Properties:
    %{~ if hive_metastore_backend == "glue" ~}
    "hive.metastore.client.factory.class": "com.amazonaws.glue.catalog.metastore.AWSGlueDataCatalogHiveClientFactory"
    %{~ endif ~}
    %{~ if hive_metastore_backend == "aurora" ~}
    "hive.txn.manager": "org.apache.hadoop.hive.ql.lockmgr.DbTxnManager"
    "hive.enforce.bucketing": "true"
    "hive.exec.dynamic.partition.mode": "nostrict"
    "hive.compactor.initiator.on": "true"
    "hive.compactor.worker.threads": "1"
    "hive.support.concurrency": "true"
    "javax.jdo.option.ConnectionURL": "jdbc:mysql://${hive_metastore_endpoint}:3306/${hive_metastore_database_name}"
    "javax.jdo.option.ConnectionDriverName": "org.mariadb.jdbc.Driver"
    "javax.jdo.option.ConnectionUserName": "${hive_metsatore_username}"
    "javax.jdo.option.ConnectionPassword": "${hive_metastore_pwd}"
    "hive.metastore.client.socket.timeout": "7200"
    %{~ endif ~}

- Classification: "hive-site"
  Properties:
    %{~ if hive_metastore_backend == "glue" ~}
    "hive.metastore.client.factory.class": "com.amazonaws.glue.catalog.metastore.AWSGlueDataCatalogHiveClientFactory"
    %{~ endif ~}
    %{~ if hive_metastore_backend == "aurora" ~}
    "hive.metastore.warehouse.dir": "s3://${s3_published_bucket}/analytical-dataset/hive/external"
    "hive.txn.manager": "org.apache.hadoop.hive.ql.lockmgr.DbTxnManager"
    "hive.enforce.bucketing": "true"
    "hive.exec.dynamic.partition.mode": "nostrict"
    "hive.compactor.initiator.on": "true"
    "hive.compactor.worker.threads": "1"
    "hive.support.concurrency": "true"
    "javax.jdo.option.ConnectionURL": "jdbc:mysql://${hive_metastore_endpoint}:3306/${hive_metastore_database_name}?createDatabaseIfNotExist=true"
    "javax.jdo.option.ConnectionDriverName": "org.mariadb.jdbc.Driver"
    "javax.jdo.option.ConnectionUserName": "${hive_metsatore_username}"
    "javax.jdo.option.ConnectionPassword": "${hive_metastore_pwd}"
    "hive.metastore.client.socket.timeout": "7200"
    %{~ endif ~}
    "hive.mapred.mode": "nonstrict"
    "hive.strict.checks.cartesian.product": "false"
    "hive.exec.parallel": "true"
    "hive.exec.parallel.thread.number": "128"
    "hive.exec.failure.hooks": "org.apache.hadoop.hive.ql.hooks.ATSHook"
    "hive.exec.post.hooks": "org.apache.hadoop.hive.ql.hooks.ATSHook"
    "hive.exec.pre.hooks": "org.apache.hadoop.hive.ql.hooks.ATSHook"
    "hive.vectorized.execution.enabled": "false"
    "hive.vectorized.execution.reduce.enabled": "false"
    "hive.vectorized.complex.types.enabled": "false"
    "hive.vectorized.use.row.serde.deserialize": "false"
    "hive.vectorized.execution.ptf.enabled": "false"
    "hive.vectorized.row.serde.inputformat.excludes": ""
    "hive_timeline_logging_enabled": "true"
    "mapred.job.queue.name": "mrqueue"
    "mapreduce.job.queuename": "mrqueue"
    "hive.server2.tez.default.queues": "appqueue1, appqueue2"
    "hive.server2.tez.sessions.per.default.queue": "15"
    "hive.server2.tez.initialize.default.sessions": "true"
    "hive.tez.auto.reducer.parallelism": "true"
    "hive.exec.reducers.bytes.per.reducer": "13421728"
    "hive.optimize.reducededuplication.min.reducer": "1"
    "hive.llap.enabled": "false"
    "hive.blobstore.optimizations.enabled": "false"
    "hive.prewarm.enabled": "true"
    "hive.tez.container.size": "${hive_tez_container_size}"
    "hive.tez.java.opts": "${hive_tez_java_opts}"
    "hive.auto.convert.join": "true"
    "hive.auto.convert.join.noconditionaltask.size": "${hive_auto_convert_join_noconditionaltask_size}"
    "hive.server2.tez.session.lifetime": "0"
    "hive.server2.async.exec.threads": "1000"
    "hive.server2.async.exec.wait.queue.size": "1000"
    "hive.server2.async.exec.keepalive.time": "60"
    "hive.tez.min.partition.factor": "0.25"
    "hive.tez.max.partition.factor": "2.0"

- Classification: "mapred-site"
  Properties:
    "mapreduce.map.resource.vcores": "3"
    "mapreduce.reduce.resource.vcores": "3"
    "mapreduce.map.memory.mb": "${yarn_map_memory}"
    "mapreduce.reduce.memory.mb": "${yarn_reduce_memory}"
    "mapreduce.map.java.opts": "${yarn_map_java_opts}"
    "mapreduce.reduce.java.opts": "${yarn_reduce_java_opts}"
    "yarn.scheduler.minimum-allocation-mb": "${yarn_min_allocation_mb}"
    "yarn.scheduler.maximum-allocation-mb": "${yarn_max_allocation_mb}"
    "yarn.app.mapreduce.am.resource.mb": "${yarn_app_mapreduce_am_resource_mb}"
    "mapred.job.queue.name": "mrqueue"
    "mapreduce.job.queuename": "mrqueue"
    "yarn.nodemanager.resource.memory-mb": "${yarn_node_manager_resource_mb}"
    "yarn.scheduler.minimum-allocation-mb": "${yarn_min_allocation_mb}"
    "yarn.scheduler.maximum-allocation-mb": "${yarn_max_allocation_mb}"
    "yarn.app.mapreduce.am.resource.vcores": "10"
    "mapred.reduce.tasks": "-1"

- Classification: "tez-site"
  Properties:
    "tez.task.resource.memory.mb": "${tez_task_resource_memory_mb}"
    "tez.grouping.min-size": "${tez_grouping_min_size}"
    "tez.grouping.max-size": "${tez_grouping_max_size}"
    "tez.am.resource.memory.mb": "${tez_am_resource_memory_mb}"
    "tez.am.launch.cmd-opts": "${tez_am_launch_cmd_opts}"
    "tez.am.container.reuse.enabled": "true"
    "tez.runtime.pipelined.sorter.lazy-allocate.memory": "true"
    "tez.am.container.reuse.non-local-fallback.enabled": "true"
    "tez.am.container.reuse.locality.delay-allocation-millis": "120000"
    "tez.runtime.io.sort.mb": "${tez_runtime_io_sort_mb}"
    "tez.runtime.unordered.output.buffer.size-mb": "${tez_runtime_unordered_output_buffer_size_mb}"

- Classification: "emrfs-site"
  Properties:
    "fs.s3.maxConnections": "10000"
    "fs.s3.maxRetries": "20"

- Classification: "spark-env"
  Configurations:
  - Classification: "export"
    Properties:
      "PYSPARK_PYTHON": "/usr/bin/python3"
      "S3_PUBLISH_BUCKET": "${s3_published_bucket}"
      "S3_HTME_BUCKET": "${s3_htme_bucket}"

- Classification: "hadoop-env"
  Configurations:
  - Classification: "export"
    Properties:
      "HADOOP_NAMENODE_OPTS": "\"-javaagent:/opt/emr/metrics/dependencies/jmx_prometheus_javaagent-0.14.0.jar=7101:/opt/emr/metrics/prometheus_config.yml\""
      "HADOOP_DATANODE_OPTS": "\"-javaagent:/opt/emr/metrics/dependencies/jmx_prometheus_javaagent-0.14.0.jar=7103:/opt/emr/metrics/prometheus_config.yml\""

- Classification: "yarn-env"
  Configurations:
  - Classification: "export"
    Properties:
      "YARN_RESOURCEMANAGER_OPTS": "\"-javaagent:/opt/emr/metrics/dependencies/jmx_prometheus_javaagent-0.14.0.jar=7105:/opt/emr/metrics/prometheus_config.yml\""
      "YARN_NODEMANAGER_OPTS": "\"-javaagent:/opt/emr/metrics/dependencies/jmx_prometheus_javaagent-0.14.0.jar=7107:/opt/emr/metrics/prometheus_config.yml\""
