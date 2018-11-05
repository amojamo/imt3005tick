# Control Repo for Deploy Tickstack with Puppet
Written by [Adrian Moen](https://github.com/amojamo). and [Askil Olsen](https://github.com/askilao). for IMT3004 Infrastructure as Code project fall 2018

This repo is not used when deploying the stack, but is used my the server provisioning tool to install and configure the TICK stack.
The service is deployed using the [Openstack HEAT template](https://github.com/amojamo/IaC-heat-k8s).

Here's a visual representation of the structure of this repository:

```
control-repo/
├── data/                                 # Hiera data directory.
│   ├── nodes/                            # Node-specific data goes here.
│   └── common.yaml                       # Common data goes here.
├── manifests/
│   └── site.pp                           # The "main" manifest that contains a default node definition.
├── scripts/
│   ├── code_manager_config_version.rb    # A config_version script for Code Manager.
│   ├── config_version.rb                 # A config_version script for r10k.
│   └── config_version.sh                 # A wrapper that chooses the appropriate config_version script.
├── site/                                 # This directory contains site-specific modules and is added to $modulepath.
│   ├── profile/                          # The profile module.
│   └── role/                             # The role module.
├── LICENSE
├── Puppetfile                            # A list of external Puppet modules to deploy with an environment.
├── README.md
├── environment.conf                      # Environment-specific settings. Configures the moduelpath and config_version.
└── hiera.yaml                            # Hiera's configuration file. The Hiera hierarchy is defined here.

