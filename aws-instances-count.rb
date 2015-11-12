#!/usr/bin/env ruby
# encoding: UTF-8

require 'yaml'
require 'logger'
require_relative 'aws'
require_relative 'instances'
require_relative 'metrics'

def read_config(conf_file = 'config')
  config_path = File.expand_path("../conf/#{conf_file}.yml", __FILE__)
  begin
    config = YAML.load_file(config_path)
    return config
  rescue Exception => e
    @logger.error("Failed to load config file #{config_path}. Cause: #{e.message}")
    abort
  end
end

def init_logger
  @logger = Logger.new(STDOUT)
  @logger.level = Logger.const_get('DEBUG')
  @logger.formatter = proc do |severity, datetime, progname, msg|
    "#{datetime.strftime('%Y-%m-%d %H:%M:%S.%3N')}" + "[#{severity}]".rjust(8) + ": #{msg}\n"
  end
end

def process_aws_account(name, access_key, secret_key, region, enable_info)

  aws_util = AwsUtil.new access_key, secret_key, region
  instances = Instances.new

  count_classes = {}
  ebs_list = []
  ecu = 0.0
  cpu = 0.0
  mem = 0.0
  cost = 0.0
  aws_util.get_all_running_instances().reservations.each do |r|
    r.instances.each do |i|

      # Counters
      count_classes[i.instance_type] += 1 if count_classes[i.instance_type]
      count_classes[i.instance_type] = 1 unless count_classes[i.instance_type]
      cost += instances.get_cost(i.instance_type, region)
      ecu += instances.get_ecu(i.instance_type)
      cpu += instances.get_cpu(i.instance_type)
      mem += instances.get_mem(i.instance_type)

      # For all EBS volumes, append the vol-id in list
      i.block_device_mappings.each do |v|
        if v.ebs and v.ebs.volume_id
          ebs_list << v.ebs.volume_id
        end
      end
    end
  end

  count_classes.each do |k,v|
    @logger.info("[#{name}][#{region}] instance:#{k}=#{v}")
    @metrics.add("#{name}.#{region}", "ec2.#{k}.count", v)
  end

  if enable_info["cost"]
    @metrics.add("#{name}.#{region}", "ec2.cost.sum", cost.round(2))
    @logger.info("[#{name}][#{region}] cost:#{cost.round(2)}")
  end
  if enable_info["ecu"]
    @metrics.add("#{name}.#{region}", "ec2.ecu.sum", ecu.round(2))
    @logger.info("[#{name}][#{region}] ecu:#{ecu.round(2)}")
  end
  if enable_info["cpu"]
    @metrics.add("#{name}.#{region}", "ec2.cpu.sum", cpu.round(0))
    @logger.info("[#{name}][#{region}] cpu:#{cpu.round(0)}")
  end
  if enable_info["mem"]
    @metrics.add("#{name}.#{region}", "ec2.mem.sum", mem.round(2))
    @logger.info("[#{name}][#{region}] mem:#{mem.round(2)}")
  end

  if enable_info["ebs"]

    # Get informations about volumes attached on instances
    count_volumes = {}
    aws_util.get_all_attached_volumes_by_ids(ebs_list).volumes.each do |v|
      type = v.volume_type
      type = "#{type}_#{v.iops}" unless type != "io1"
      count_volumes[type] += v.size if count_volumes[type]
      count_volumes[type] = v.size unless count_volumes[type]
    end

    count_volumes.each do |k,v|
      @logger.info("[#{name}][#{region}] ebs:#{k}=#{v}")
      @metrics.add("#{name}.#{region}", "ebs.#{k}.sum", v)
    end

  end

end

init_logger
@logger.info("Initialize aws-instances-count.rb...")
@conf = read_config
@metrics = Metrics.new @conf, @logger

@conf["aws_accounts"].each do |c|
  c["regions"].each do |r|
    @logger.info("Process account #{c["name"]} to region #{r}...")
    process_aws_account(c["name"], c["access_key"], c["secret_key"],
                        r, c["enable_info"])
  end
end

@metrics.send

@logger.info("Ended process.")
