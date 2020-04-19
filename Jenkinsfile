def BranchName() {
   if ( env.BRANCH_NAME == null ) {
       branchstring=scm.branches[0].name
       return branchstring.substring(2)
   } else {
       return env.BRANCH_NAME.replaceAll('/','_')
   }
}

def build_docker_image_dev(String profile){
  sh '''
    docker build -t aa047267/spinnaker:web-deployment-'''+env.VERSION+'''-'''+profile+''' .
    docker login -u aa047267 -p ashit5712
    docker push aa047267/spinnaker:web-deployment-'''+env.VERSION+'''-'''+profile+'''
    echo IMAGE-TAG=web-deployment-'''+env.VERSION+'''-'''+profile+''' > dev-image.tag
    cd helm-charts
    helm package app-ui/
    aws s3 cp app-ui-0.1.0.tgz s3://miq-devops-repo/spinnaker-test/
    cd .. 
  '''
}

def build_docker_image_pre_prod(String profile){
  sh '''
    docker build -t aa047267/spinnaker:web-deployment-'''+env.VERSION+'''-'''+profile+''' .
    docker login -u aa047267 -p ashit5712
    docker push aa047267/spinnaker:web-deployment-'''+env.VERSION+'''-'''+profile+'''
    echo IMAGE-TAG=web-deployment-'''+env.VERSION+'''-'''+profile+''' > pre-prod-image.tag
    cd helm-charts
    helm package app-ui/
    aws s3 cp app-ui-0.1.0.tgz s3://miq-devops-repo/spinnaker-test/
    cd .. 
  '''
}

def build_docker_image_prod(String profile){
  sh '''
    docker build -t aa047267/spinnaker:web-deployment-'''+env.VERSION+'''-'''+profile+''' .
    docker login -u aa047267 -p ashit5712
    docker push aa047267/spinnaker:web-deployment-'''+env.VERSION+'''-'''+profile+'''
    echo IMAGE-TAG=web-deployment-'''+env.VERSION+'''-'''+profile+''' > prod-image.tag
    cd helm-charts
    helm package app-ui/
    aws s3 cp app-ui-0.1.0.tgz s3://miq-devops-repo/spinnaker-test/
    cd .. 
  '''
}


pipeline {
    agent any
    environment {
        VERSION = "2.10.0"
        ENV = "staging"
        DEV_BRANCH_NAME = "development"
        CUR_BRANCH_NAME = BranchName()
        PROD_BRANCH_NAME = "master"

   }
    options {
      disableConcurrentBuilds()
      buildDiscarder(logRotator(numToKeepStr:'5'))
    }


    
    stages {

        stage('SCM Checkout'){
          steps{
            git changelog: false, poll: false, url: 'https://github.com/AA047267/web-deployment.git'
          }
        }

        stage('BUILD AND PUSH IMAGE - DEV') {
          when {
            expression {
                return env.CUR_BRANCH_NAME == env.DEV_BRANCH_NAME;
            }
          }
          steps{
            script{
                build_docker_image_dev('dev')
            }
          }
        }

        stage('BUILD AND PUSH IMAGE - PRE-PROD') {
          when {
            expression {
                return env.CUR_BRANCH_NAME.startsWith('release');
            }
          }
          steps{
            script{
                build_docker_image_pre_prod('pre-prod')
            }
          }
        }

        stage('BUILD AND PUSH IMAGE - PROD') {
          when {
            expression {
                return env.CUR_BRANCH_NAME == env.PROD_BRANCH_NAME;
            }
          }
          steps{
            script{
                build_docker_image_prod('prod')
            }
          }
        }


    }
    post{
      always{
          archiveArtifacts artifacts: 'dev-image.tag', followSymlinks: false
          archiveArtifacts artifacts: 'pre-prod-image.tag', followSymlinks: false
          archiveArtifacts artifacts: 'prod-image.tag', followSymlinks: false
          cleanWs()
      }
    }
}
