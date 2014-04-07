# Version 0.1.0

require 'json'

require '../config'
require './providers'

Instances = []

#
# Define hydra servers
#
def hydraServerProvision(cloud, prize, name, domain)
  return hydraProbeProvisionV2(cloud, 2, 2, prize, name, "hydra", "8443", name, "/var/run/hydra_server_api.pid", domain,"http")
end

hydraPeers=""
for i in 1..NUM_HYDRA_SERVERS
  name = PREFIX + "hydra#{i}"
  instance = {
    'name' => name,
    'providers' => {
      :default => {
        "provisions" => [
          {"path" => "./vagrant-deploy-common/scripts/updatedns.sh","args" => "#{name}"},
          {"path" => "scripts/hydraServer.sh", "args" => "#{name} #{hydraPeers}"},
          {"path" => "./vagrant-deploy-common/scripts/redirectTraffic.sh", "args"  => "#{name} 8080 8080" },
          {"path" => "./vagrant-deploy-common/scripts/redirectTraffic.sh", "args"  => "#{name} 8443 8443" }
        ]
      },
      :aws => {
        :oregon => {
          "attributes" => makeAWSInstanceAttributes(name, AWS_HYDRA_INSTANCE_TYPE, AWS_OR_AMI),
          "provisions" => [ hydraServerProvision("amazon-oregon", 7, name, "aws-oregon.innotechapp.com") ]
        },
        :ireland => {
          "attributes" => makeAWSInstanceAttributes(name, AWS_HYDRA_INSTANCE_TYPE, AWS_EU_AMI),
          "provisions" => [ hydraServerProvision("amazon-ireland", 5, name, "aws-ireland.innotechapp.com") ]
        }
      },
      :google => {
        :any => {
          "attributes" => makeGCEInstanceAttributes(name, GCE_HYDRA_INSTANCE_TYPE, GCE_AMI),
          "provisions" => [ hydraServerProvision("google-#{GCE_ZONE}", 3, name, "gce.innotechapp.com") ]
        }
      }
    }
  }

  if hydraPeers != ""
    hydraPeers = hydraPeers[0...-1]
  end
  hydraPeers += (hydraPeers == "" ? "'" : ",") + "\"" + name + ":7001" + "\""
  hydraPeers += (hydraPeers != "" ? "'" : "")
  # hydraPeers += (hydraPeers != "" ? " " : "") + name
  Instances.push(instance)
end

#
# Define time servers
#
def hydraTimeProvision(cloud, prize, name, domain)
  return hydraProbeProvisionV2(cloud, 2, 2, prize, name, "time", "8080", name, "/var/run/time.pid", domain,"http")
end

for i in 1..NUM_TIME_SERVERS
  name = PREFIX + "time#{i}"
  instance = {
    'name' => name,
    'providers' => {
      :default => {
        "provisions" => [
          {"path" => "./vagrant-deploy-common/scripts/updatedns.sh","args" => "#{name}"},
          {"path" => "scripts/timeServer.sh"},
          {"path" => "./vagrant-deploy-common/scripts/redirectTraffic.sh", "args"  => "#{name} 8080 8080"}
        ]
      },
      :aws => {
        :oregon => {
          "attributes" => makeAWSInstanceAttributes(name, AWS_TIME_INSTANCE_TYPE, AWS_OR_AMI),
          "provisions" => [ hydraTimeProvision("amazon-oregon", 7, name, "aws-oregon.innotechapp.com") ]
        },
        :ireland => {
          "attributes" => makeAWSInstanceAttributes(name, AWS_TIME_INSTANCE_TYPE, AWS_EU_AMI),
          "provisions" => [ hydraTimeProvision("amazon-ireland", 5, name, "aws-ireland.innotechapp.com") ]
        }
      },
      :google => {
        :any => {
          "attributes" => makeGCEInstanceAttributes(name, GCE_TIME_INSTANCE_TYPE, GCE_AMI),
          "provisions" => [ hydraTimeProvision("google-#{GCE_ZONE}", 3, name, "gce.innotechapp.com") ]
        }
      }
    }
  }
  Instances.push(instance)
end