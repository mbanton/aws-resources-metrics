aws-resources-metrics
==================================

Collection of Ruby script to send count and usage of aws resources of multiple aws accounts to metrics arround the time

## Installation to run in script mode

* To install scripts you will need: ruby >= 2.2 and bundler

* Once you have ruby and bundler you can do this:

  ```bash
  # Install ruby dependencies
  bundle install

  # Copy configuration template to config.yml
  cp conf/config.yml.sample conf/config.yml

  # Configure your config.yml with yours aws accounts and other parameters
  vim conf/config.yml

  # Run scripts
  ./aws-instances-count.rb
  ```

* Put in cron at some machine. Recommended interval is 5 minutes.

## Using docker

* Build the container

  ```bash
  docker build -t aws-resources-metrics .
  ```

* Run the container passing the script you want to run

  ```bash
  docker run -v $PWD:/opt/aws-resources-metrics/ --rm aws-resources-metrics ./aws-instances-count.rb
  ```

### Recommended EC2 Permissions

* Below is the only necessary permissions in AWS to get required data.

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "ec2:DescribeInstances",
                "ec2:DescribeVolumes"
            ],
            "Effect": "Allow",
            "Resource": [
                "*"
            ]
        }
    ]
}
```

### Thanks to

 - [ec2instances.info project](https://github.com/powdahound/ec2instances.info), for the instances.json data file

### TODO

* Save the data in CSV besides sending metrics
