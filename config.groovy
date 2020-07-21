drmanVersion = 'master'
drmanNamespace = 'DIDman'
distributionBranch = 'dist'
candidateBranch = 'candidates'
candidateRepoVersion = '1'
environments {
	local {
		candidatesApi = 'http://localhost:8080/2'
	}
	production {
		candidatesApi = 'https://raw.githubusercontent.com/${DRMAN_NAMESPACE}/DRman/blob/${candidateBranch}/${distributionBranch}/{candidateRepoVersion}'
		// Default => candidatesApi = 'https://raw.githubusercontent.com/DIDman/DRman/canditates/dist/1'
	
	}
}