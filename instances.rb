require 'json'

class Instances

  def initialize()
    file = File.read("data/instances.json")
    @data_hash = JSON.parse(file)
    @cache = {}
  end

  def find_instance(instance)
    unless @cache[instance]
      @cache[instance] = @data_hash.find { |h| h['instance_type'] == instance }
    end
    @cache[instance]
  end

  def get_cost(instance, region, so="linux", type="ondemand")
    i = find_instance(instance)
    i["pricing"][region][so][type].to_f if i and i["pricing"] and i["pricing"][region]
  end

  def get_ecu(instance)

    # Force ECU in t2 instance, because in json have 0 ECU
    family, type = instance.split(".")
    if family == "t1" or family == "t2"
      if type == "medium" or type == "large"
        return 2
      else
        return 1
      end
    end

    i = find_instance(instance)
    i["ECU"].to_f if i and i["ECU"]
  end

  def get_cpu(instance)
    i = find_instance(instance)
    i["vCPU"].to_f if i and i["vCPU"]
  end

  def get_mem(instance)
    i = find_instance(instance)
    i["memory"].to_f if i and i["memory"]
  end

end
