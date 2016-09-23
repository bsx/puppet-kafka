Puppet::Type.newtype(:kafka_topic) do

    ensurable

    autorequire(:class) do
        'kafka::broker'
    end

    newparam(:name, :namevar => true) do
        desc "The name of the topic."
        newvalues(/^[\w_\-\.]+$/)
    end

    newproperty(:options) do
        desc "additional options for the topic"
    end

    newproperty(:replication_factor) do
        desc "number of replicas to create for the topic"
    end

    newproperty(:partitions) do
        desc "number of partitions"
    end

end