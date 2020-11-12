# DRman
DID Registry Manager

A tool to set up a DID registry for an organization on GitHub.

You can read up on DID(https://www.w3.org/TR/did-core/) and what a DID registry is. 

More details about this project is available at.

Hyperledger Wiki link. https://wiki.hyperledger.org/pages/viewpage.action?pageId=31195277

## Installation

Open your favourite terminal and enter the following:

    $ curl -s https://raw.githubusercontent.com/DIDman/DRman/dist/dist/get.drman.io | bash

If the environment needs tweaking for DRMAN to be installed, the installer will prompt you accordingly and ask you to restart.

## Running the Cucumber Features

All DRMAN's BDD tests describing the CLI behaviour are written in Cucumber and can be found under `src/test/cucumber/drman`. These can be run with Gradle by running the following command:

    $ ./gradlew test

### Using Docker for tests

You can run the tests in a Docker container to guarantee a clean test environment.

    $ docker build --tag=drman/gradle .
    $ docker run --rm -it drman/gradle test

By running the following command, you don't need to wait for downloading Gradle wrapper and other dependencies. The test reports can be found under the local `build` directory.

    $ docker run --rm -it -v $PWD:/usr/src/app -v $HOME/.gradle:/root/.gradle drman/gradle test

### Local Installation

To install DRMAN locally running against your local server, run the following commands:

	$ ./gradlew install
	$ source ~/.drman/bin/drman-init.sh

Or run install locally with Production configuration:

	$ ./gradlew -Penv=production install
	$ source ~/.drman/bin/drman-init.sh
	
### Track the Progress	
	
	To know more about the current progress of this project , please check PROGRESS_REPORT.md file
	
### Design Aspects

The significant aspects to be considered here are Creation, Onboarding(Enable/Restrict Access) and  Manage(add/update/revoke) .

a) Creation (of DIDRegistry) : Function to create a DIDRegistry for an organization on Github. GitHub Organization can have multiple repository , same is the case with DID Registries.

b) Onboarding : Function to add enable/restrict access to members of an organization to a repository (GitHub repo users can be made members of an Organization, with different roles and privileges).

c) Manage: Function to list APIs that are needed  to add/update/revoke access DID’s or (DID Documents) saved as files on the repo .

### Design Summary - DRman Registry Scripts :

1. DRman Registry scripts (DRM scripts ) 
     - Drm scripts are simples shell scripts of the format drm_xxxx.sh, where xxxx is the didRegistry Type e.g. drm_aries_vcr.sh or drm_aries_vcgr.sh are two different type of didRegistries supported.They will be used to create, install, manage a didRegistry associated with an organization.  


2. Github based VCR (Verifiable Credential Registry)

     - Github based VCR are Verfiable credential registries that make use of Github’s datamodel and api to offer exactly the same API’s as any other VCR. Further, We need to make comparison API & data model of both Github and Aries VCR.

3. Create and manage  Aries VCR using DRman Registry Script

      - Plan is to have a script drm_aries_vcr.sh with all functionality like install, uninstall, add . etc supported in it. This plan can be executed independently

4. Create and manage Aries-VCGR ( Aries Verifiable Credential Github Registry ) using DRman Registry Scripts. While progressing , this can be done after along with the Design of Github based VCR (As mentioned in the point 2)
	

At present, The project facilitates the creation of Verifiable Credential Registry for the user with the permissions enabled/disabled. The user can choose to use Github /Gitlab/Other as his datastore. To make a encrypted push/pull gpg as well as gitcrypt libraries are tried. Test design and execution was experimented. Later, its found Hyperledger Ursa seems to be a viable solution to present a zero knowledge proof (https://crates.io/crates/ursa)! More details will be updated soon.

We welcome more people to be an active contributer to this wonderful project.You can reach out to people currently working on this project by joining the slack 

https://join.slack.com/t/drmanvcr/shared_invite/zt-iw1svhdz-MwBeGYdnjajNUKc0wm7ulA 

### Resources

https://github.com/cloudcompass/ToIPLabs/tree/master/docs/LFS173x

https://github.com/hyperledger/aries-cloudagent-python/blob/master/demo/AriesOpenAPIDemo.md

https://github.com/bcgov/aries-vcr/tree/master/server/vcr-server

https://courses.edx.org/courses/course-v1:LinuxFoundationX+LFS172x+3T2019/course/
	
