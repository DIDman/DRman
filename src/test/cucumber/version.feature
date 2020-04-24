Feature: Version

	Scenario: Show the current version of drman
		Given the internet is reachable
		And the drman version is "3.2.1"
		And an initialised environment
		And the system is bootstrapped
		When I enter "drmversion"
		Then I see "DRMAN 3.2.1"
