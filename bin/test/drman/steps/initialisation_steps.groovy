package drman.steps

import drman.env.DRmanBashEnvBuilder
import drman.stubs.UnameStub

import java.util.zip.ZipException
import java.util.zip.ZipFile

import static cucumber.api.groovy.EN.And
import static drman.stubs.WebServiceStub.primeEndpointWithString
import static drman.stubs.WebServiceStub.primeSelfupdate
import static drman.support.UnixUtils.asDRmanPlatform

def BROADCAST_MESSAGE = "broadcast message"

And(~'^the drman work folder is created$') { ->
	assert drmanDir.isDirectory(), "The DRMAN directory does not exist."
}

And(~'^the "([^"]*)" folder exists in user home$') { String arg1 ->
	assert drmanDir.isDirectory(), "The DRMAN directory does not exist."
}

And(~'^the archive for candidate "([^"]*)" version "([^"]*)" is corrupt$') { String candidate, String version ->
	try {
		new ZipFile(new File("src/test/resources/__files/${candidate}-${version}.zip"))
		assert false, "Archive was not corrupt!"
	} catch (ZipException ze) {
		//expected behaviour
	}
}

And(~'^the archive for candidate "([^"]*)" version "([^"]*)" is removed$') { String candidate, String version ->
	def archive = new File("${drmanDir}/archives/${candidate}-${version}.zip")
	assert !archive.exists()
}

And(~'^the internet is reachable$') { ->
	primeEndpointWithString("/broadcast/latest/id", "12345")
	primeEndpointWithString("/broadcast/latest", BROADCAST_MESSAGE)
	primeEndpointWithString("/app/stable", drmanVersion)
	primeSelfupdate()

	offlineMode = false
	serviceUrlEnv = SERVICE_UP_URL
	javaHome = FAKE_JDK_PATH
}

And(~'^the internet is not reachable$') { ->
	offlineMode = false
	serviceUrlEnv = SERVICE_DOWN_URL
	javaHome = FAKE_JDK_PATH
}

And(~'^offline mode is disabled with reachable internet$') { ->
	primeEndpointWithString("/broadcast/latest/id", "12345")
	primeEndpointWithString("/broadcast/latest", BROADCAST_MESSAGE)
	primeEndpointWithString("/app/stable", drmanVersion)

	offlineMode = false
	serviceUrlEnv = SERVICE_UP_URL
	javaHome = FAKE_JDK_PATH
}

And(~'^offline mode is enabled with reachable internet$') { ->
	primeEndpointWithString("/broadcast/latest/id", "12345")
	primeEndpointWithString("/broadcast/latest", BROADCAST_MESSAGE)
	primeEndpointWithString("/app/stable", drmanVersion)

	offlineMode = true
	serviceUrlEnv = SERVICE_UP_URL
	javaHome = FAKE_JDK_PATH
}

And(~'^offline mode is enabled with unreachable internet$') { ->
	offlineMode = true
	serviceUrlEnv = SERVICE_DOWN_URL
	javaHome = FAKE_JDK_PATH
}

And(~'^a machine with "(.*)" installed$') { String platform ->
	def binFolder = "$drmanBaseDir/bin" as File
	UnameStub.prepareIn(binFolder)
			.forPlatform(asDRmanPlatform(platform))
			.build()
}

And(~'^an initialised environment$') { ->
	bash = DRmanBashEnvBuilder.create(drmanBaseDir)
			.withOfflineMode(offlineMode)
			.withCandidatesApi(serviceUrlEnv)
			.withJdkHome(javaHome)
			.withHttpProxy(HTTP_PROXY)
			.withVersionCache(drmanVersion)
			.withCandidates(localCandidates)
			.withDRmanVersion(drmanVersion)
			.build()
}

And(~'^an initialised environment without debug prints$') { ->
	bash = DRmanBashEnvBuilder.create(drmanBaseDir)
			.withOfflineMode(offlineMode)
			.withCandidatesApi(serviceUrlEnv)
			.withJdkHome(javaHome)
			.withHttpProxy(HTTP_PROXY)
			.withVersionCache(drmanVersion)
			.withCandidates(localCandidates)
			.withDRmanVersion(drmanVersion)
			.withDebugMode(false)
			.build()
}

And(~'^an outdated initialised environment$') { ->
	bash = DRmanBashEnvBuilder.create(drmanBaseDir)
			.withOfflineMode(offlineMode)
			.withCandidatesApi(serviceUrlEnv)
			.withJdkHome(javaHome)
			.withHttpProxy(HTTP_PROXY)
			.withVersionCache(drmanVersionOutdated)
			.withDRmanVersion(drmanVersionOutdated)
			.build()

	def twoDaysAgoInMillis = System.currentTimeMillis() - 172800000

	def upgradeFile = "$drmanDir/var/delay_upgrade" as File
	upgradeFile.createNewFile()
	upgradeFile.setLastModified(twoDaysAgoInMillis)

	def versionFile = "$drmanDir/var/version" as File
	versionFile.setLastModified(twoDaysAgoInMillis)

	def initFile = "$drmanDir/bin/drman-init.sh" as File
	initFile.text = initFile.text.replace(drmanVersion, drmanVersionOutdated)
}

And(~'^the system is bootstrapped$') { ->
	bash.start()
	bash.execute("source $drmanDirEnv/bin/drman-init.sh")
}

And(~'^the system is bootstrapped again$') { ->
	bash.execute("source $drmanDirEnv/bin/drman-init.sh")
}

And(~/^the drman version is "([^"]*)"$/) { String version ->
	drmanVersion = version
}

And(~/^the candidates cache is initialised with "(.*)"$/) { String candidate ->
	localCandidates << candidate
}
