# Version 0.1.0

require 'json'

require '../config'
require './providers'

Instances = []

#
# Define hydra servers
#
def hydraProbeForHydraServer(cloud, prize, name, domain)
  return hydraProbeProvisionV3(cloud, 2, 2, prize, name, "hydra", "8080", name, "/var/run/hydra.pid", domain, "http")
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
          {"path" => "scripts/hydra.sh", "args" => "#{name} #{hydraPeers}"},
          {"path" => "./vagrant-deploy-common/scripts/redirectTraffic.sh", "args"  => "#{name} 8080 8080" },
          {"path" => "./vagrant-deploy-common/scripts/redirectTraffic.sh", "args"  => "#{name} 8443 8443" },
          {"path" => "./vagrant-deploy-common/scripts/redirectTraffic.sh", "args"  => "#{name} 9099 9099" }
        ]
      },
      :aws => {
        :oregon => {
          "attributes" => makeAWSInstanceAttributes(name, AWS_HYDRA_INSTANCE_TYPE, AWS_OR_AMI),
          "provisions" => [ hydraProbeForHydraServer("amazon-oregon", 7, name, "aws-oregon.innotechapp.com") ]
        },
        :ireland => {
          "attributes" => makeAWSInstanceAttributes(name, AWS_HYDRA_INSTANCE_TYPE, AWS_EU_AMI),
          "provisions" => [ hydraProbeForHydraServer("amazon-ireland", 5, name, "aws-ireland.innotechapp.com") ]
        }
      },
      :google => {
        :any => {
          "attributes" => makeGCEInstanceAttributes(name, GCE_HYDRA_INSTANCE_TYPE, GCE_AMI),
          "provisions" => [ hydraProbeForHydraServer("google-#{GCE_ZONE}", 3, name, "gce.innotechapp.com") ]
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
def hydraProbeForTimeServer(cloud, prize, name, hydra, domain)
  return hydraProbeProvisionV2(cloud, 2, 2, prize, name, "time", "8080", hydra, "/var/run/time.pid", domain,"http")
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
          {"path" => "./vagrant-deploy-common/scripts/redirectTraffic.sh", "args"  => "#{name} 8080 8080"},
          {"path" => "./vagrant-deploy-common/scripts/redirectTraffic.sh", "args"  => "#{name} 9099 9099" },
          {"path" => "./vagrant-deploy-common/scripts/redirectTraffic.sh", "args"  => "#{name} 5000 5000" }
        ]
      },
      :aws => {
        :oregon => {
          "attributes" => makeAWSInstanceAttributes(name, AWS_TIME_INSTANCE_TYPE, AWS_OR_AMI),
          "provisions" => [ hydraProbeForTimeServer("amazon-oregon", 7, name, PREFIX + "hydra3", "aws-oregon.innotechapp.com") ]
        },
        :ireland => {
          "attributes" => makeAWSInstanceAttributes(name, AWS_TIME_INSTANCE_TYPE, AWS_EU_AMI),
          "provisions" => [ hydraProbeForTimeServer("amazon-ireland", 5, name, PREFIX + "hydra2", "aws-ireland.innotechapp.com") ]
        }
      },
      :google => {
        :any => {
          "attributes" => makeGCEInstanceAttributes(name, GCE_TIME_INSTANCE_TYPE, GCE_AMI),
          "provisions" => [ hydraProbeForTimeServer("google-#{GCE_ZONE}", 3, name, PREFIX + "hydra1", "gce.innotechapp.com") ]
        }
      }
    }
  }
  Instances.push(instance)
end
