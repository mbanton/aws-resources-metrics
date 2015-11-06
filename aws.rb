require 'aws-sdk'

class AwsUtil

  def initialize(access_key, secret_key, region)
    Aws.config.update({
      region: region,
      credentials: Aws::Credentials.new(access_key, secret_key),
    })
    @ec2_client = Aws::EC2::Client.new
  end

  def get_all_running_instances
    # Get informations about instances
    begin
      ec2_resp = @ec2_client.describe_instances({
        filters: [
          {
            name: "instance-state-name",
            values: ["running"],
          },
        ],
        max_results: 1000
      })
    rescue Aws::EC2::Errors::ServiceError => error
      puts "failed when calling aws ec2 api: #{error.message}"
      abort
    end
    ec2_resp

  end

  def get_all_attached_volumes_by_ids(ids)
    begin
      ec2_vol_resp = @ec2_client.describe_volumes({
        volume_ids: ids,
        filters: [
          {
            name: "attachment.status",
            values: ["attached"],
          },
        ]
      })
    rescue Aws::EC2::Errors::ServiceError => error
      puts "failed when calling aws ec2 api: #{error.message}"
      abort
    end
    ec2_vol_resp

  end

end
