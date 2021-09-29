# September 14, 2021

## Things in Progress: 
- [ ] Figure out a detailed workflow for RF-0.0.1
- [ ] Procedure to create a repository for a Github/Non-Github organization


## Things I have done: 
- [x] Explore a set of GitHub API involved
  - [x] A list of all involved GitHub API 

- [x] Explore Hyperledger Aries Project (roughly)
  - [x] Install and text Aries Python CloudAgent 


# August 23, 2021 

## Things In Progess: 
- [ ] Explore Hyperledger Aries Project (roughly)
  - [] Install and text Aries Python CloudAgent 

- [ ] Explore a set of GitHub API involved
  - [] A list of all involved GitHub API 

- [ ] Procedure to create a repository for a Github/Non-Github organization


## Things I have done: 
- [x] Warm up by Project Setup - DRman (https://github.com/DIDman/DRman)
  - [x] Fixed few installation Issues
  - [x] Explored about s2i

- [x] Check up with the progress of previous project

- [x] Explore VC Registry (Check relevant W3C standard documents)
  - [x] Checked Verifiable Credentials Data Model 1.0 (https://www.w3.org/TR/vc-data-model/)
  - [x] Checked Decentralized Identifiers (DIDs) v1.0 (https://www.w3.org/TR/did-core/)
  - [x] Checked Verifiable Credentials Implementation Guidelines 1.0 (https://www.w3.org/TR/vc-imp-guide/)

- [x] Explore DRM commands
  - [x] Checked helper/create-github-vcr.sh
  - [x] Checked helper/delete-github-vcr.sh

- [x] Explore DID repository

- [x] The architecuture of DRMAN in verfiable credential model 

- [x] Explore Von-network 
  - [x] Installed on local machine and AWS 


# November 11, 2020
 
## Things In progres for demo:
- Working on the Architecture
	- [x]  Version 3 : https://docs.google.com/document/d/1Yryir_OV-VgIiAJeXZkL7t8jCvUtEy57ci1fGZueHhg/edit?usp=sharing


# September 04, 2020
 
### Upcoming Goal: Work on RF-0.0.1 (https://github.com/DIDman/DRman/issues/3) 

### Things I'll Do next week: August 2020
- [ ] Will work on https://github.com/DIDman/DRman/issues/3
	- [ ]  Create a compatable schema for the, Yet to be created Github Repo  -- In Progress
	- [ ]  Script Integration with  Drman -- In Progress
	

## Things I have done last week:
- Working on https://github.com/DIDman/DRman/issues/3
	- [x]  Explored the schema of Hyperledger Aries
	- [x]  Made a script to create a dummy github repo

# August 24, 2020
 
### Upcoming Goal: Work on RF-0.0.1 (https://github.com/DIDman/DRman/issues/3) 

### Things I'll Do next week: August 2020
- [ ] Will work on https://github.com/DIDman/DRman/issues/3
	- [ ]  Explore the schema of Hyperledger Aries
	- [ ]  Create a compatable schema for the, Yet to be created Github Repo 
	- [ ]  Make a script to create a dummy github repo
	- [ ]  Make a script to create dummy schema from Drman
	

## Things I have done last week:
- [x] HL Indy Email Verification Service Setup
  - [x] Fixed few installation Issues
  - [x] Explored about s2i

- [x] Experimented with Aries Cloudagent Python
  - [x] Enabled communication with Alice & Faber withouT Ledger using swagger
  - [x] Credentials issued by Faber Agent
  - [x] Placed Verifiable Credentials in the public ledger to enable the presentation of proofs 
 
 - [x] Aries VCR Setup
  - [x] VON Network Setup Successful
  - [x] Facing quiet a few issues with Aries VCR

### Backlog: Side Projects :)
- [ ] NA

### Backlog: Code Things I Want to Do/Play With
- [ ] NA



# August 17, 2020

## Things I'll Do This sprint:
- [x] Exploring more at https://courses.edx.org/courses/course-v1:LinuxFoundationX+LFS173x+1T2020/course/
- [ ] Decouple BCGov Docker images and Replace it with our docker image for testing
- [x] Installation of Aries Ecosystem

### Things I'll Do This Month: August 2020
- [ ] Write a blog post 
- [x] Initiate a sprint progress update in github

### Backlog: Side Projects :)
- [ ] NA

### Backlog: Code Things I Want to Do/Play With
1. Aries Sample Code


## Goals 

 To create, install, manage a didRegistry associated with an organization. 
 
 Enable a Zero Infrastructure cost.
 
 Enable trusted communication via Verifiable Credential Registry.
 
 Utilize Aries ecosystem to enable plug and play infrastruture.

 
## Why Verifiable Credential Regsitry 

  VCR Stands on its own
  
  VCR Works on top of the github
  

## Points to Remember
   Github acts as the datastore here
   
   No Infrastructure cost involved as we are using Github as our underlying infrastructure
   
   The script should be able to install Hyperledger Aries in the target location
   
   No dependency with any third party tools liks Github or Gitlab. Open to change its base installation location anytime
   
   Github Based VCR vs Non Github Based VCR
  
  	1. Github based VCR are Verfiable credential registries that make use of Github’s datamodel and api to offer exactly the same API’s as any other VCR
  
  	2. Create and manage  Aries VCR using DRman Registry Script
  
  	3. Create and manage Aries-VCGR 
   
   

# Short Term Goal
1. Explore the Email Verification Service 
2. Experiment by replacing the BCGov Docker images with our own docker images
3. Make a periodic Commits in Github
4. Get better at shell scripting
5. Learn more about Aries Ecosystem
6. Install Hyperledger Aries

