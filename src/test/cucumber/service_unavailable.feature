Feature: Service Unavailable

	Background:
		Given the internet is not reachable
		And an initialised environment

	# list commands

	Scenario: List candidate versions found while Offline
		Given the candidate "grails" version "2.1.0" is already installed and default
		And the candidate "grails" version "1.3.9" is already installed but not default
		And the system is bootstrapped
		When I enter "drmlist grails"
		Then I see "Offline: only showing installed grails versions"
		And I see "> 2.1.0"
		And I see "* 1.3.9"

	Scenario: List candidate versions not found while Offline
		Given the system is bootstrapped
		When I enter "drmlist grails"
		Then I see "Offline: only showing installed grails versions"
		And I see "None installed!"

	Scenario: List Available Candidates while Offline
		Given the system is bootstrapped
		When I enter "drmlist"
		Then I see "This command is not available while offline."

	# use command

	Scenario: Use the default candidate version when non selected while Offline
		Given the candidate "grails" version "1.3.9" is already installed but not default
		And the candidate "grails" version "2.1.0" is already installed but not default
		And the system is bootstrapped
		When I enter "drmuse grails"
		Then I see "No candidate version provided."

	Scenario: Use an uninstalled candidate version while Offline
		Given the candidate "grails" version "1.3.9" is already installed and default
		And the candidate "grails" version "2.1.0" is not installed
		And the system is bootstrapped
		When I enter "drmuse grails 2.1.0"
		Then I see "Stop! grails 2.1.0 is not available while offline."

	Scenario: Use an invalid candidate version while Offline
		Given the candidate "grails" version "1.3.9" is already installed and default
		And the system is bootstrapped
		When I enter "drmuse grails 9.9.9"
		Then I see "Stop! grails 9.9.9 is not available while offline."

	Scenario: Use an installed candidate version while Offline
		Given the candidate "grails" version "2.1.0" is already installed and default
		And the candidate "grails" version "1.3.9" is already installed but not default
		And the system is bootstrapped
		When I enter "drmuse grails 1.3.9"
		Then I see "Using grails version 1.3.9 in this shell."

	# default command

	Scenario: Set the default to an uninstalled candidate version while Offline
		Given the candidate "grails" version "1.3.9" is already installed and default
		And the system is bootstrapped
		When I enter "drmdefault grails 2.1.0"
		Then I see "Stop! grails 2.1.0 is not available while offline."

	Scenario: Set the default to an invalid candidate version while Offline
		Given the candidate "grails" version "1.3.9" is already installed and default
		And the system is bootstrapped
		When I enter "drmdefault grails 999"
		Then I see "Stop! grails 999 is not available while offline."

	Scenario: Set the default to an installed candidate version while Offline
		Given the candidate "grails" version "2.1.0" is already installed and default
		And the candidate "grails" version "1.3.9" is already installed but not default
		And the system is bootstrapped
		When I enter "drmdefault grails 1.3.9"
		Then I see "Default grails version set to 1.3.9"

	# install command

	Scenario: Install a candidate version that is not installed while Offline
		Given the candidate "grails" version "2.1.0" is not installed
		And the system is bootstrapped
		When I enter "drminstall grails 2.1.0"
		Then I see "Stop! grails 2.1.0 is not available while offline."

	Scenario: Install a candidate version that is already installed while Offline
		Given the candidate "grails" version "2.1.0" is already installed and default
		And the system is bootstrapped
		When I enter "drminstall grails 2.1.0"
		Then I see "Stop! grails 2.1.0 is already installed."

	# uninstall command

	Scenario: Uninstall a candidate version while Offline
		Given the candidate "grails" version "2.1.0" is already installed and default
		And the system is bootstrapped
		When I enter "drmuninstall grails 2.1.0"
		Then I see "Deselecting grails 2.1.0..."
		And I see "Uninstalling grails 2.1.0..."
		And the candidate "grails" version "2.1.0" is not in use
		And the candidate "grails" version "2.1.0" is not installed

	Scenario: Uninstall a candidate version that is not installed while Offline
		Given the candidate "grails" version "2.1.0" is not installed
		And the system is bootstrapped
		When I enter "drmuninstall grails 2.1.0"
		Then I see "grails 2.1.0 is not installed."

	# current command

	Scenario: Display the current version of a candidate while Offline
		Given the candidate "grails" version "2.1.0" is already installed and default
		And the system is bootstrapped
		When I enter "drmcurrent grails"
		Then I see "Using grails version 2.1.0"

	Scenario: Display the current version of all candidates while Offline
		Given the candidate "grails" version "2.1.0" is already installed and default
		And the candidate "groovy" version "2.0.5" is already installed and default
		And the system is bootstrapped
		When I enter "drmcurrent"
		Then I see "Using:"
		And I see "grails: 2.1.0"
		And I see "groovy: 2.0.5"

	# version command

	Scenario: Determine the drman version when Offline
		Given the system is bootstrapped
		When I enter "drmversion"
		Then I see the current drman version

	# broadcast command

	Scenario: Recall a broadcast while Offline
		Given a prior Broadcast "This is an OLD Broadcast!" with id "12344" was issued
		And the system is bootstrapped
		When I enter "drmbroadcast"
		Then I see "This is an OLD Broadcast!"

	# help command

	Scenario: Request help while Offline
		Given the system is bootstrapped
		When I enter "drmhelp"
		Then I see "Usage: drm <command> [candidate] [version]"

	# selfupdate command

	Scenario: Attempt self-update while Offline
		Given the system is bootstrapped
		When I enter "drmselfupdate"
		Then I see "This command is not available while offline."
