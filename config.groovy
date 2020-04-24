drmanVersion = 'master'
environments {
	local {
		candidatesApi = 'http://localhost:8080/2'
	}
	production {
		candidatesApi = 'https://raw.githubusercontent.com/DIDman/DRman/candidates/candidates/1'
	}
}
