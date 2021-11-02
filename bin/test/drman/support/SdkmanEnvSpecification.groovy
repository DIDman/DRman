package drman.support

import drman.env.DRmanBashEnvBuilder
import drman.stubs.CurlStub

import static drman.support.FilesystemUtils.prepareBaseDir

abstract class DRmanEnvSpecification extends BashEnvSpecification {

	DRmanBashEnvBuilder DRmanBashEnvBuilder

	CurlStub curlStub

	File drmanBaseDirectory
	File drmanDotDirectory
	File candidatesDirectory

	String bootstrapScript

	def setup() {
		drmanBaseDirectory = prepareBaseDir()
		curlStub = CurlStub.prepareIn(new File(drmanBaseDirectory, "bin"))
		DRmanBashEnvBuilder = DRmanBashEnvBuilder
				.create(drmanBaseDirectory)
				.withCurlStub(curlStub)

		drmanDotDirectory = new File(drmanBaseDirectory, ".drman")
		candidatesDirectory = new File(drmanDotDirectory, "candidates")
		bootstrapScript = "${drmanDotDirectory}/bin/drman-init.sh"
	}

	def cleanup() {
		assert drmanBaseDirectory.deleteDir()
	}
}
