Prefix_command = "./wrapper.sh"

Machines = {
	"hydra" => {
		"google" => {
			"any" => [
				"hydra1"
			]
		},
		"aws" => {
			"ireland" => [
				"hydra2"
			],
			"oregon" => [
				"hydra3"
			]
		}
	},
	"time" => {
    "google" => {
      "any" => [
        "time1"
      ]
    },
    "aws" => {
      "ireland" => [
        "time2",
        "time5"
      ],
      "oregon" => [
        "time3",
        "time6"
      ]
    }
  }
}

Dependencies = [
  ["hydra1","time1"],
  ["hydra2","time2","time5"],
  ["hydra3","time3","time6"]
]

Actions = {
	"hydra" => {
		"up" => ["deploy"],
		"down" => ["get_destroy"]
	},
	"time" => {
    "up" => ["deploy"],
    "down" => ["get_destroy"]
  }
}