package drman.steps

import com.github.tomakehurst.wiremock.client.WireMock
import drman.support.FilesystemUtils
import drman.support.UnixUtils
import drman.support.WireMockServerProvider

import static cucumber.api.groovy.Hooks.After
import static cucumber.api.groovy.Hooks.Before

HTTP_PROXY = System.getProperty("httpProxy") ?: ""
PLATFORM = UnixUtils.platform.toLowerCase()

FAKE_JDK_PATH = "/path/to/my/openjdk"
SERVICE_UP_HOST = "localhost"
SERVICE_UP_PORT = 8080
SERVICE_UP_URL = "http://$SERVICE_UP_HOST:$SERVICE_UP_PORT"
SERVICE_DOWN_URL = "http://localhost:0"

counter = "${(Math.random() * 10000).toInteger()}".padLeft(4, "0")

localGroovyCandidate = "/tmp/groovy-core" as File

drmanVersion = "5.0.0"
drmanVersionOutdated = "4.0.0"

drmanBaseEnv = FilesystemUtils.prepareBaseDir().absolutePath
drmanBaseDir = drmanBaseEnv as File

drmanDirEnv = "$drmanBaseEnv/.drman"
drmanDir = drmanDirEnv as File
candidatesDir = "${drmanDirEnv}/candidates" as File
binDir = "${drmanDirEnv}/bin" as File
srcDir = "${drmanDirEnv}/src" as File
varDir = "${drmanDirEnv}/var" as File
etcDir = "${drmanDirEnv}/etc" as File
extDir = "${drmanDirEnv}/ext" as File
archiveDir = "${drmanDirEnv}/archives" as File
tmpDir = "${drmanDir}/tmp" as File

broadcastFile = new File(varDir, "broadcast")
broadcastIdFile = new File(varDir, "broadcast_id")
candidatesFile = new File(varDir, "candidates")
versionFile = new File(varDir, "version")
initScript = new File(binDir, "drman-init.sh")

localCandidates = ['groovy', 'grails', 'java', 'kotlin', 'scala']

bash = null

if (!binding.hasVariable("wireMock")) {
	wireMock = WireMockServerProvider.wireMockServer()
}

addShutdownHook {
	wireMock.stop()
}

Before() {
	WireMock.reset()
	cleanUp()
}

private cleanUp() {
	drmanBaseDir.deleteDir()
	localGroovyCandidate.deleteDir()
}

After() { scenario ->
	def output = bash?.output
	if (output) {
		scenario.write("\nOutput: \n${output}")
	}
	bash?.stop()
}
