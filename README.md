# DRman
DID Registry Manager

A tool to set up a DID registry for an organization on GitHub.

You can read up on DID(https://www.w3.org/TR/did-core/) and what a DID registry is. 

More details about this project is available at.

Hyperledger Wiki link. https://wiki.hyperledger.org/pages/viewpage.action?pageId=31195277
 

## Goal 

 To create, install, manage a didRegistry associated with an organization. 
 
 Enable a Zero Infrastructure cost.
 
 Enable trusted communication via Verifiable Credential Registry.
 
 Utilize Aries ecosystem to enable plug and play infrastruture.

 
## Why Verifiable Credential Regsitry 

  VCR Stands on its own
  
  VCR Works on top of the github
  

## Points to Remember
   Github acts as the datastore here
   
   No Infrastructure cost involved as we are using Github as our underlying infrastructure
   
   The script should be able to install Hyperledger Aries in the target location
   
   No dependency with any third party tools liks Github or Gitlab. Open to change its base installation location anytime
   
   Github Based VCR vs Non Github Based VCR
  
  	1. Github based VCR are Verfiable credential registries that make use of Github’s datamodel and api to offer exactly the same API’s as any other VCR
  
  	2. Create and manage  Aries VCR using DRman Registry Script
  
  	3. Create and manage Aries-VCGR 
   
   

# Short Term Goal
1. Explore the Email Verification Service 
2. Experiment by replacing the BCGov Docker images with our own docker images
3. Make a periodic Commits in Github
4. Get better at shell scripting
5. Learn more about Aries Ecosystem
6. Install Hyperledger Aries

# August 17, 2020

### This Sprint's Goal: Install Aries VCR.

## Things I'll Do This sprint:
- [x] Exploring more at https://courses.edx.org/courses/course-v1:LinuxFoundationX+LFS173x+1T2020/course/
- [ ] Decouple BCGov Docker images and Replace it with our docker image for testing
- [ ] Installation of Aries Ecosystem

### Things I'll Do This Month: August 2020
- [ ] Write a blog post
- [x] Initiate a sprint progress update in github

### Backlog: Side Projects :)
- [ ] NA

### Backlog: Code Things I Want to Do/Play With
1. Aries Sample Code


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

	
