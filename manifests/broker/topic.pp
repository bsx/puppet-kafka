# Author::    Liam Bennett  (mailto:lbennett@opentable.com)
# Copyright:: Copyright (c) 2013 OpenTable Inc
# License::   MIT

# == Define: kafka::broker::topic
#
# This private class is meant to be called from `kafka::broker`.
# It manages the creation of topics on the kafka broker
#
# This resource only exists for backwards compatibility, it uses the new provider type.
define kafka::broker::topic(
  $ensure             = '',
  $zookeeper          = '',
  $replication_factor = 1,
  $partitions         = 1,
  $options            = {},
) {

  kafka_topic{ $name:
    ensure             => $ensure,
    replication_factor => $replication_factor,
    partitions         => $partitions,
    options            => $options,
  }

}
