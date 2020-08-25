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
