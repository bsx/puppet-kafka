Puppet::Type.type(:kafka_topic).provide(:cli) do
    initvars

    commands :topics => '/opt/kafka/bin/kafka-topics.sh', :configs => '/opt/kafka/bin/kafka-configs.sh'

    mk_resource_methods

    def initialize(value={})
        super(value)
        @removed_configs = []
        @added_configs = {}
    end

    def exists?
        @property_hash[:ensure] == :present || false
    end

    def self.instances
        Puppet.debug('loading instances')
        topics([zookeeper_opts, '--list'].compact).split("\n").collect do |name|
            name = name.split(/\s/).first if name =~ /\s/

            new({
                :name               => name,
                :ensure             => :present,
                :partitions         => 0,
                :replication_factor => 0,
                :options            => {},
            })
        end
    end

    def load_topic_data
        Puppet.debug("loading info for #{@property_hash[:name]}")
        topics([zookeeper_opts, '--describe', '--topic', @property_hash[:name]]).split("\n").first.split(/\s/).each do |attribute|
            Puppet.debug("found attribute #{attribute}")
            attrib_name, attrib_value = attribute.split(':')
            @property_hash[:partitions] = attrib_value if attrib_name == 'PartitionCount'
            @property_hash[:replication_factor] = attrib_value if attrib_name == 'ReplicationFactor'
            if attrib_name == 'Configs' and attrib_value
                attrib_value.split(',').collect do |config|
                    k,v = config.split('=')
                    @property_hash[:options][k] = v
                end
            end
        end
    end

    def self.prefetch(resources)
        topics = instances
        resources.keys.each do |topic|
            if provider = topics.find { |t| t.name == topic }
                provider.load_topic_data
                resources[topic].provider = provider
            end
        end
    end

    def create
        topics([zookeeper_opts, '--create', '--topic', @resource[:name],
                '--replication-factor', @resource[:replication_factor],
                '--partitions', @resource[:partitions],
                config_opts(@resource[:options])].compact)

        @property_hash[:ensure]             = :present
        @property_hash[:partitions]         = @resource[:partitions]
        @property_hash[:replication_factor] = @resource[:replication_factor]
        @property_hash[:options]            = @resource[:options]

        exists? ? (return true) : (return false)
    end

    def destroy
        topics([zookeeper_opts, '--delete', '--topic', @resource[:name]].compact)

        @property_hash.clear
        exists? ? (return false) : (return true)
    end

    def flush
        if @removed_configs.length > 0
            configs([zookeeper_opts, '--alter', '--entity-name', @resource[:name],
                    '--entity-type', 'topics', '--delete-config', @removed_configs.join(',')].compact)
        end
        if @added_configs.length > 0
            configs([zookeeper_opts, '--alter', '--entity-name', @resource[:name],
                    '--entity-type', 'topics', addconfig_opts(@added_configs)].compact)
        end
        @property_hash.clear
    end

    def options=(value)
        current = @property_hash[:options]
        value.keys.each do |k|
            if current.has_key? k
                if current[k] != value[k]
                    @added_configs[k] = value[k]
                end
            else
                @added_configs[k] = value[k]
            end
        end
        current.keys.each do |k|
            unless value.has_key? k
                @removed_configs << k
            end
        end
    end

    def self.zookeeper_opts
        ['--zookeeper', 'localhost:2181']
    end

    def self.config_opts(configs)
        opts = []
        configs.each do |k,v|
            opts << '--config'
            opts << "#{k}=#{v}"
        end
        return opts
    end

    def self.addconfig_opts(configs)
        opts = []
        configs.each do |k,v|
            opts << '--add-config'
            opts << "#{k}=#{v}"
        end
        return opts
    end

    def zookeeper_opts
        self.class.zookeeper_opts
    end

    def config_opts(configs)
        self.class.config_opts(configs)
    end

    def addconfig_opts(configs)
        self.class.addconfig_opts(configs)
    end
end