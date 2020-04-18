def BranchName() {
   if ( env.BRANCH_NAME == null ) {
       branchstring=scm.branches[0].name
       return branchstring.substring(2)
   } else {
       return env.BRANCH_NAME.replaceAll('/','_')
   }
}

def build_docker_image(String profile){
  sh '''
    docker build -t aa047267/spinnaker:web-deployment-'''+env.VERSION+'''-'''+profile+''' .
    docker login -u aa047267 -p ashit5712
    docker push aa047267/spinnaker:web-deployment-'''+env.VERSION+'''-'''+profile+''' 
  '''
}

def deploy_dev(String environment, String namespace){
  sh '''
    cd helm-charts
    helm package app-ui/
    helm upgrade --install --force helm-deployment-'''+environment+''' --tiller-namespace spinnaker app-ui-0.1.0.tgz -f app-ui/values-'''+environment+'''.yaml --namespace '''+namespace+'''
    cd ..
  '''
}

def deploy_pre_prod(String environment, String namespace){
  sh '''
    cd helm-charts
    helm package app-ui/
    helm upgrade --install --force helm-deployment-'''+environment+''' --tiller-namespace spinnaker app-ui-0.1.0.tgz -f app-ui/values-'''+environment+'''.yaml --namespace '''+namespace+'''
    cd ..
  '''
}

def deploy_prod(String environment, String namespace){
  sh '''
    cd helm-charts
    helm package app-ui/
    helm upgrade --install --force helm-deployment-'''+environment+''' --tiller-namespace spinnaker app-ui-0.1.0.tgz -f app-ui/values-'''+environment+'''.yaml --namespace '''+namespace+'''
    cd ..
  '''
}

pipeline {
    agent any
    environment {
        VERSION = "1.10.0"
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
                build_docker_image('dev')
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
                build_docker_image('pre-prod')
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
                build_docker_image('prod')
            }
          }
        }

        stage('DEPLOY - DEV') {
          when {
            expression {
                return env.CUR_BRANCH_NAME == env.DEV_BRANCH_NAME;
            }
          }
          steps{
            script{
                deploy_dev('dev', 'testing-spinnaker-dev')
            }
          }
        }

        stage('DEPLOY - PRE-PROD') {
          when {
            expression {
                return env.CUR_BRANCH_NAME.startsWith('release');
            }
          }
          steps{
            script{
                deploy_pre_prod('pre-prod', 'testing-spinnaker-pre-prod')
            }
          }
        }

        stage('DEPLOY - PROD') {
          when {
            expression {
                return env.CUR_BRANCH_NAME == env.PROD_BRANCH_NAME;
            }
          }
          steps{
            script{
                deploy_prod('prod', 'testing-spinnaker-prod')
            }
          }
        }

      
    }
}
