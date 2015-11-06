aws-resources-metrics
==================================

Collection of Ruby script to send count and usage of aws resources of multiple aws accounts to metrics arround the time

### Recommended EC2 Permissions

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
