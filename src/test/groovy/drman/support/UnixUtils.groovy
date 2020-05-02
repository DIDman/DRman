package drman.support

class UnixUtils {

	static getPlatform() {
		asDRmanPlatform(System.getProperty("os.name"))
	}

	static asDRmanPlatform(platform) {
		def result
		switch (platform) {
			case "Mac OS X":
				result = "Darwin"
				break
			case "Linux":
				result = "Linux64"
				break
			case "Linux 64":
				result = "Linux64"
				break
			case "Linux 32":
				result = "Linux32"
				break
			case "FreeBSD":
				result = "FreeBSD"
				break
			default:
				result = platform
		}
		result
	}
}
