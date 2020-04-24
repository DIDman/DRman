@manual
Feature: Self Update

	Background:
		Given the internet is reachable

	Scenario: Force a Selfupdate
		Given an initialised environment
		And the system is bootstrapped
		When I enter "drmselfupdate force"
		Then I do not see "A new version of DRMAN is available..."
		And I do not see "Would you like to upgrade now? (Y/n)"
		And I do not see "Not upgrading today..."
		And I see "Updating DRMAN..."
		And I see "Successfully upgraded DRMAN."

	Scenario: Selfupdate when out of date
		Given an outdated initialised environment
		And the system is bootstrapped
		When I enter "drmselfupdate"
		Then I do not see "A new version of DRMAN is available..."
		And I do not see "Would you like to upgrade now? (Y/n)"
		And I do not see "Not upgrading today..."
		And I see "Updating DRMAN..."
		And I see "Successfully upgraded DRMAN."

	Scenario: Agree to a suggested Selfupdate
		Given an outdated initialised environment
		And the system is bootstrapped
		When I enter "drmhelp" and answer "Y"
		Then I see "A new version of DRMAN is available..."
		And I see "Would you like to upgrade now? (Y/n)"
		And I see "Successfully upgraded DRMAN."
		And I do not see "Not upgrading today..."

	Scenario: Do not agree to a suggested Selfupdate
		Given an outdated initialised environment
		And the system is bootstrapped
		When I enter "drmhelp" and answer "N"
		Then I see "A new version of DRMAN is available..."
		And I see "Would you like to upgrade now? (Y/n)"
		And I see "Not upgrading today..."
		And I do not see "Successfully upgraded DRMAN."

	Scenario: Automatically Selfupdate
		Given an outdated initialised environment
		And the configuration file has been primed with "drman_auto_selfupdate=true"
		And the system is bootstrapped
		When I enter "drmhelp"
		Then I see "A new version of DRMAN is available..."
		And I do not see "Would you like to upgrade now? (Y/n)"
		And I do not see "Not upgrading today..."
		And I see "Successfully upgraded DRMAN."

	Scenario: Do not automatically Selfupdate
		Given an outdated initialised environment
		And the configuration file has been primed with "drman_auto_selfupdate=false"
		And the system is bootstrapped
		When I enter "drmhelp" and answer "n"
		Then I see "A new version of DRMAN is available..."
		And I see "Would you like to upgrade now? (Y/n)"
		And I see "Not upgrading today..."
		And I do not see "Successfully upgraded DRMAN."

	Scenario: Bother the user with Upgrade message once a day
		Given an outdated initialised environment
		And the system is bootstrapped
		When I enter "drmhelp" and answer "N"
		Then I see "A new version of DRMAN is available..."
		And I see "Would you like to upgrade now? (Y/n)"
		And I see "Not upgrading today..."
		And I enter "drmhelp"
		Then I do not see "A new version of DRMAN is available..."
		And I do not see "Would you like to upgrade now? (Y/n)"
		And I do not see "Not upgrading now..."
		And I do not see "Successfully upgraded DRMAN."

	Scenario: Selfupdate when not out of date
		Given an initialised environment
		And the system is bootstrapped
		When I enter "drmselfupdate"
		Then I see "No update available at this time."
