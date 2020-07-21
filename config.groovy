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
		candidatesApi = 'https://raw.githubusercontent.com/${DRMAN_NAMESPACE}/DRman/blob/${DRMAN_CANDIDATE_BRANCH}/${distributionBranch}/{DRMAN_CANDIDATE_REPO_VERSION}'
		// Default => candidatesApi = 'https://raw.githubusercontent.com/DIDman/DRman/blob/canditates/dist/1'
	
	}
}