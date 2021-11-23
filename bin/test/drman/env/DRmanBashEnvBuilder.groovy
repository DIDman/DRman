package drman.env

import groovy.transform.ToString
import drman.stubs.CurlStub

@ToString(includeNames = true)
class DRmanBashEnvBuilder {

	final TEST_SCRIPT_BUILD_DIR = "build/scripts" as File

	//mandatory fields
	private final File baseFolder

	//optional fields with sensible defaults
	private Optional<CurlStub> curlStub = Optional.empty()
	private List candidates = ['groovy', 'grails', 'java']
	private boolean offlineMode = false
	private String broadcast = "This is a LIVE broadcast!"
	private String candidatesApi = "http://localhost:8080/2"
	private String drmanVersion = "0.0.1"
	private String jdkHome = "/path/to/my/jdk"
	private String httpProxy
	private String versionCache
	private boolean debugMode = true

	Map config = [
			drman_auto_answer : 'false',
			drman_beta_channel: 'false'
	]

	File drmanDir, drmanBinDir, drmanVarDir, drmanSrcDir, drmanEtcDir, drmanExtDir, drmanArchivesDir, drmanTmpDir, drmanCandidatesDir

	static DRmanBashEnvBuilder create(File baseFolder) {
		new DRmanBashEnvBuilder(baseFolder)
	}

	private DRmanBashEnvBuilder(File baseFolder) {
		this.baseFolder = baseFolder
	}

	DRmanBashEnvBuilder withCurlStub(CurlStub curlStub) {
		this.curlStub = Optional.of(curlStub)
		this
	}

	DRmanBashEnvBuilder withCandidates(List candidates) {
		this.candidates = candidates
		this
	}

	DRmanBashEnvBuilder withBroadcast(String broadcast) {
		this.broadcast = broadcast
		this
	}

	DRmanBashEnvBuilder withConfiguration(String key, String value) {
		config.put key, value
		this
	}

	DRmanBashEnvBuilder withOfflineMode(boolean offlineMode) {
		this.offlineMode = offlineMode
		this
	}

	DRmanBashEnvBuilder withCandidatesApi(String service) {
		this.candidatesApi = service
		this
	}

	DRmanBashEnvBuilder withJdkHome(String jdkHome) {
		this.jdkHome = jdkHome
		this
	}

	DRmanBashEnvBuilder withHttpProxy(String httpProxy) {
		this.httpProxy = httpProxy
		this
	}

	DRmanBashEnvBuilder withVersionCache(String version) {
		this.versionCache = version
		this
	}

	DRmanBashEnvBuilder withDRmanVersion(String version) {
		this.drmanVersion = version
		this
	}

	DRmanBashEnvBuilder withDebugMode(boolean debugMode) {
		this.debugMode = debugMode
		this
	}

	BashEnv build() {
		drmanDir = prepareDirectory(baseFolder, ".drman")
		drmanBinDir = prepareDirectory(drmanDir, "bin")
		drmanVarDir = prepareDirectory(drmanDir, "var")
		drmanSrcDir = prepareDirectory(drmanDir, "src")
		drmanEtcDir = prepareDirectory(drmanDir, "etc")
		drmanExtDir = prepareDirectory(drmanDir, "ext")
		drmanArchivesDir = prepareDirectory(drmanDir, "archives")
		drmanTmpDir = prepareDirectory(drmanDir, "tmp")
		drmanCandidatesDir = prepareDirectory(drmanDir, "candidates")

		curlStub.map { cs -> cs.build() }

		initializeCandidates(drmanCandidatesDir, candidates)
		initializeCandidatesCache(drmanVarDir, candidates)
		initializeBroadcast(drmanVarDir, broadcast)
		initializeConfiguration(drmanEtcDir, config)
		initializeVersionCache(drmanVarDir, versionCache)

		primeInitScript(drmanBinDir)
		primeModuleScripts(drmanSrcDir)

		def env = [
				DRMAN_DIR           : drmanDir.absolutePath,
				DRMAN_CANDIDATES_DIR: drmanCandidatesDir.absolutePath,
				DRMAN_OFFLINE_MODE  : "$offlineMode",
				DRMAN_CANDIDATES_API: candidatesApi,
				DRMAN_VERSION       : drmanVersion,
				drman_debug_mode    : Boolean.toString(debugMode),
				JAVA_HOME            : jdkHome
		]

		if (httpProxy) {
			env.put("http_proxy", httpProxy)
		}

		def bashEnv = new BashEnv(baseFolder.absolutePath, env)
		println("\nDRmanBashEnvBuilder: $this")
		println("\nBashEnv: $bashEnv")
		bashEnv
	}

	private prepareDirectory(File target, String directoryName) {
		def directory = new File(target, directoryName)
		directory.mkdirs()
		directory
	}

	private initializeVersionCache(File folder, String version) {
		if (version) {
			new File(folder, "version") << version
		}
	}


	private initializeCandidates(File folder, List candidates) {
		candidates.each { candidate ->
			new File(folder, candidate).mkdirs()
		}
	}

	private initializeCandidatesCache(File folder, List candidates) {
		def candidatesCache = new File(folder, "candidates")
		if (candidates) {
			candidatesCache << candidates.join(",")
		} else {
			candidatesCache << ""
		}
	}

	private initializeBroadcast(File targetFolder, String broadcast) {
		new File(targetFolder, "broadcast") << broadcast
	}

	private initializeConfiguration(File targetFolder, Map config) {
		def configFile = new File(targetFolder, "config")
		config.each { key, value ->
			configFile << "$key=$value\n"
		}
	}

	private primeInitScript(File targetFolder) {
		def sourceInitScript = new File(TEST_SCRIPT_BUILD_DIR, 'drman-init.sh')

		if (!sourceInitScript.exists())
			throw new IllegalStateException("drman-init.sh has not been prepared for consumption.")

		def destInitScript = new File(targetFolder, "drman-init.sh")
		destInitScript << sourceInitScript.text
		destInitScript
	}

	private primeModuleScripts(File targetFolder) {
		for (f in TEST_SCRIPT_BUILD_DIR.listFiles()) {
			if (!(f.name in ['selfupdate.sh', 'install.sh', 'drman-init.sh'])) {
				new File(targetFolder, f.name) << f.text
			}
		}
	}
}
