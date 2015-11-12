require 'librato/metrics'

class Metrics

  def initialize(conf, logger)
    @logger = logger
    @logger.info("Initialize librato metrics sender...")
    Librato::Metrics.authenticate conf["metrics"]["librato"]["email"],
                                  conf["metrics"]["librato"]["token"]
    @prefix = conf["metrics"]["librato"]["all_metric_prefix"]
    @measure_time = Time.now
    @queue = Librato::Metrics::Queue.new
  end

  def add(source, metric, value)
    metric_name = "#{@prefix}.#{metric}"
    @queue.add metric_name => {:measure_time => @measure_time, :type => :gauge, :value => value, :source => source}
  end

  def send()
    @logger.info("Sending librato metrics queue...")
    @queue.submit
  end

end
