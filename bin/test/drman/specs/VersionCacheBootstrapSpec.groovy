package drman.specs

import drman.support.DRmanEnvSpecification

import static java.lang.System.currentTimeMillis

class VersionCacheBootstrapSpec extends DRmanEnvSpecification {

	static final MORE_THAN_A_DAY_IN_MILLIS = 24 * 61 * 60 * 1000

	static final CANDIDATES_API = "http://localhost:8080/2"
	static final CLI_VERSION_STABLE_ENDPOINT = "$CANDIDATES_API/broker/download/drman/version/stable"
	static final CLI_VERSION_BETA_ENDPOINT = "$CANDIDATES_API/broker/download/drman/version/beta"
	static final CANDIDATES_ENDPOINT = "$CANDIDATES_API/candidates"

	File versionCache

	def setup() {
		versionCache = new File("${drmanDotDirectory}/var", "version")
		curlStub.primeWith(CANDIDATES_ENDPOINT, "echo 'groovy,scala'")
	}

	void "should store version cache if does not exist"() {
		given:
		curlStub.primeWith(CLI_VERSION_STABLE_ENDPOINT, "echo x.y.b")
		bash = DRmanBashEnvBuilder.build()

		and:
		bash.start()

		when:
		bash.execute("source $bootstrapScript")
		bash.execute("sdk version")

		then:
		versionCache.exists()
		versionCache.text.contains("x.y.b")
	}

	void "should not query server if unexpired version cache is found"() {
		given:
		curlStub.primeWith(CLI_VERSION_STABLE_ENDPOINT, "sleep 50") //will timeout and fail if called
		bash = DRmanBashEnvBuilder
				.withVersionCache("x.y.z")
				.build()

		and:
		bash.start()

		when:
		bash.execute("source $bootstrapScript")
		bash.execute("sdk version")

		then:
		versionCache.exists()
		versionCache.text.contains("x.y.z")
	}

	void "should refresh version cache if older than a day"() {
		given:
		curlStub.primeWith(CLI_VERSION_STABLE_ENDPOINT, "echo x.y.b")
		bash = DRmanBashEnvBuilder
				.withVersionCache("x.y.a")
				.build()

		and:
		versionCache.setLastModified(currentTimeMillis() - MORE_THAN_A_DAY_IN_MILLIS)

		and:
		bash.start()

		when:
		bash.execute("source $bootstrapScript")
		bash.execute("sdk version")

		then:
		versionCache.exists()
		versionCache.text.contains("x.y.b")
	}

	void "should fallback and ignore version if version cache expired and api is offline"() {
		given:
		curlStub.primeWith(CLI_VERSION_STABLE_ENDPOINT, "echo ''")
		bash = DRmanBashEnvBuilder
				.withVersionCache("x.y.z")
				.build()

		and:
		versionCache.setLastModified(currentTimeMillis() - MORE_THAN_A_DAY_IN_MILLIS)

		and:
		bash.start()

		when:
		bash.execute("source $bootstrapScript")
		bash.execute("sdk version")

		then:
		versionCache.text.contains("x.y.z")
	}

	void "should not go offline if curl times out"() {
		given:
		curlStub.primeWith(CLI_VERSION_STABLE_ENDPOINT, "echo ''")
		bash = DRmanBashEnvBuilder
				.withVersionCache("x.y.z")
				.build()

		and:
		versionCache.setLastModified(currentTimeMillis() - MORE_THAN_A_DAY_IN_MILLIS)

		and:
		bash.start()

		when:
		bash.execute("source $bootstrapScript")
		bash.execute("sdk version")

		then:
		!bash.output.contains("DRMAN can't reach the internet so going offline.")
	}

	void "should ignore version if api returns garbage"() {
		given:
		def drmanVersion = "x.y.z"
		curlStub.primeWith(CLI_VERSION_STABLE_ENDPOINT, "echo '<html><title>sorry</title></html>'")
		bash = DRmanBashEnvBuilder
				.withVersionCache(drmanVersion)
				.build()

		and:
		versionCache.setLastModified(currentTimeMillis() - MORE_THAN_A_DAY_IN_MILLIS)

		and:
		bash.start()

		when:
		bash.execute("source $bootstrapScript")
		bash.execute("sdk version")

		then:
		versionCache.text.contains(drmanVersion)
	}

	void "should always refresh version cache if on beta_channel"() {
		given:
		curlStub.primeWith(CLI_VERSION_BETA_ENDPOINT, "echo x.y.z")
		bash = DRmanBashEnvBuilder
				.withVersionCache("x.y.w")
				.withConfiguration("drman_beta_channel", "true")
				.build()

		and:
		bash.start()

		when:
		bash.execute("source $bootstrapScript")
		bash.execute("sdk version")

		then:
		versionCache.exists()
		versionCache.text.contains("x.y.z")
	}
}
