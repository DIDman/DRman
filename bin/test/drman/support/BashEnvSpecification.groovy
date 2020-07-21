package drman.support

import drman.env.BashEnv
import spock.lang.Specification

abstract class BashEnvSpecification extends Specification {

	BashEnv bash

	void cleanup() {
		println bash.output
		bash.stop()
	}
}
