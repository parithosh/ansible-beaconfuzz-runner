# Ansible for beacon-fuzz 

 [![Forks](https://img.shields.io/github/forks/parithosh/ansible-beaconfuzz-runner)](https://github.com/parithosh/ansible-beaconfuzz-runner/network/members)
 [![Stars](https://img.shields.io/github/stars/parithosh/ansible-beaconfuzz-runner)](https://github.com/parithosh/ansible-beaconfuzz-runner/stargazers)
 [![License: AGPL v3](https://img.shields.io/github/license/parithosh/ansible-beaconfuzz-runner)](https://github.com/parithosh/ansible-beaconfuzz-runner/blob/main/LICENSE)
  
Beacon-fuzz is an open sourced fuzzing framework for the Ethereum 2.0 Phase 0 implementation. The original
beacon-fuzz repository can be found [here](https://github.com/sigp/beacon-fuzz). 

This repository contains the ansible playbooks that can be used to perform the following actions:
- Start a fuzzer on a remote machine
- Stop a fuzzer on a remote machine
- Fetch the fuzzing artifacts from a remote machine

## Requirements: 
- A machine with ansible installed
- A remote machine or VM on which the fuzzing will be performed, ideally Ubuntu or Debian (Note: this project has been tested on Debian GNU/Linux 10)

## Setup:
- Clone this repository and navigate the terminal to the directory
- Install the ansible posix collection "ansible-galaxy collection install ansible.posix"
- Open the `inventory.ini` file and enter the information as described
- Run the desired playbook with `ansible-playbook playbooks/<name-of-playbook-here>.yml`
- The fuzzing will be started inside a `screen` on the remote machine
- If needed, observe the performance/logs by SSH-ing into to the remote machine and using `sudo screen -r` 

## Caveats: 
- The docker socket is often inaccessible on newly provisioned VMs to regular users. For the sake of simplicity, this
playbook uses the `root` user to bypass this. If a more stable solution is required, then modify the `basic-dependencies` 
role to create a user with access to the docker daemon. 
- The `screen` started by the playbook in which the fuzzer runs has been set to run under the `root` user. This has been
done to enable all `screen`s to run in one place. A potential future upgrade will use the fuzzing user method as 
described in the previous `caveat`.
- If multiple fuzzers are to be run on the same machine, then add multiple entries with the required configuration
in the `inventory.ini` file. The playbook would then fail due to some processes failing to get a lock, to avoid this, set
the playbook to run in serial mode with `serial: 1` right after the `hosts:` line in the playbook.
- The playbook `stop-all-fuzzers.yml` uses the `kill` command to stop all processes running in `screen`. However, it does 
so indiscriminately. It will stop all `screens` on the root user. Be warned of this behavior. 
- The `fetch-all-artefacts.yml` playbook creates and saves the artifacts in a folder in a folder called `fuzzing-artifacts`
- The `fetch-all-artefacts.yml` playbook has only been tested on the `beaconfuzz_v2` fuzzer. The path to the `eth2fuzz`
artefacts might be wrong and needs some attention to change it. Changes can be done via the `playbook/variables/folder-location.yaml`. 

## Future work: 
- Automate the whole process with `terraform` to provision infrastructure as well
- Test the `fetch-all-artefacts.yml` playbook to check if the locations of the fuzzing artifacts are correct
- Create a user on the remote machine purely for fuzzing
- Create a playbook that randomly runs a fuzzer without any configuration being specified 

## Contributors welcome!