package drman.steps

import static cucumber.api.groovy.EN.And

And(~/^the file "([^"]+)" exists and contains "([^"]+)"$/) { String filename, String content ->
	new File(drmanBaseEnv, filename).withWriter {
		it.writeLine(content)
	}
}
