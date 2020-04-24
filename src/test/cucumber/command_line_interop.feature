Feature: Command Line Interop

	Background:
		Given the internet is reachable
		And an initialised environment
		And the system is bootstrapped

	Scenario: Enter drm
		When I enter "drm"
		Then I see "Usage: drm <command> [candidate] [version]"
		And I see "drmoffline <enable|disable>"

	Scenario: Ask for help
		When I enter "drm help"
		Then I see "Usage: drm <command> [candidate] [version]"

	Scenario: Enter an invalid Command
		When I enter "drm goopoo grails"
		Then I see "Invalid command: goopoo"
		And I see "Usage: drm <command> [candidate] [version]"

	Scenario: Enter an invalid Candidate
		When I enter "drm install groffle"
		Then I see "Stop! groffle is not a valid candidate."
