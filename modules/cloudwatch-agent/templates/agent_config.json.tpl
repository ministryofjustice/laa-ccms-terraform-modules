{
  "agent": {
    "metrics_collection_interval": 60,
    "logfile": "/opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log",
    "run_as_user": "root"
  },
  "metrics": {
    "namespace": "CWAgent",
    "append_dimensions": {
      "InstanceId": "$${aws:InstanceId}"
    },
    "aggregation_dimensions": [["InstanceId"], ["InstanceId", "path"]],
    "metrics_collected": {
      "cpu": {
        "resources": ["*"],
        "measurement": ["cpu_usage_idle", "cpu_usage_iowait", "cpu_usage_user", "cpu_usage_system"],
        "totalcpu": false
      },
      "disk": {
        "resources": ["*"],
        "measurement": ["used_percent", "inodes_free", "disk_free"],
        "ignore_file_system_types": ["sysfs", "devtmpfs", "tmpfs", "overlay", "squashfs", "fuse.s3fs", "nfs", "nfs4"],
        "drop_device": true
      },
      "diskio": {
        "resources": ["*"],
        "measurement": ["io_time"]
      },
      "mem": {
        "measurement": ["mem_used_percent", "mem_available_percent"]
      },
      "swap": {
        "measurement": ["swap_used_percent"]
      }
    }
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/messages",
            "log_group_name": "${messages_log_group}",
            "log_stream_name": "{instance_id}"
          },
          {
            "file_path": "/var/log/secure",
            "log_group_name": "${secure_log_group}",
            "log_stream_name": "{instance_id}"
          }
        ]
      }
    }
  }
}
