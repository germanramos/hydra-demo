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
}

Dependencies = [
  ["hydra1"],
  ["hydra2"],
  ["hydra3"]
]

Actions = {
	"hydra" => {
		"up" => ["deploy"],
		"down" => ["get_destroy"]
	}
}