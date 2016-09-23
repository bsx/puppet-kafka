# Author::    Liam Bennett  (mailto:lbennett@opentable.com)
# Copyright:: Copyright (c) 2013 OpenTable Inc
# License::   MIT

# == Define: kafka::topic
#
# This defined type is used to manage the creation of kafka topics.
#
define kafka::topic(
  $ensure             = '',
  $zookeeper          = '',
  $replication_factor = 1,
  $partitions         = 1,
  $bin_dir            = '/opt/kafka/bin',
  $options            = {},
) {

  kafka_topic{ $name:
    ensure             => $ensure,
    replication_factor => $replication_factor,
    partitions         => $partitions,
    options            => $options,
  }

}
