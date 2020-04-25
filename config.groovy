drmanVersion = 'master'
drmanNamespace = 'DIDman'
distributionBranch = 'dist'
candidateBranch = 'candidates'
candidateRepoVersionNumber = '1'
environments {
	local {
		candidatesApi = 'http://localhost:8080/2'
	}
	production {
		candidatesApi = "https://raw.githubusercontent.com/${DRMAN_NAMESPACE}/DRman/${DRMAN_CANDIDATE_BRANCH}/candidates/${DRMAN_CANDIDATE_REPO_VERSION}"
		// Default => candidatesApi = 'https://raw.githubusercontent.com/DIDman/DRman/canditates/candidates/1'
	
	}
}
