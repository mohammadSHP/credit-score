pipeline {
  agent any

  environment {
    IMAGE_NAME     = "mohammadshp/credit-score"
    IMAGE_TAG      = "${env.BUILD_NUMBER}"
    DOCKERHUB_CRED = credentials('dockerhub-creds')
    GIT_CRED       = credentials('git-creds')
    GIT_REPO       = "github.com/mohammadSHP/credit-score.git"
  }

  stages {

    stage('Checkout') {
      steps { checkout scm }
    }

    stage('Run Tests') {
      agent {
        docker {
          image 'python:3.11-slim'
          args '-u root'
        }
      }
      steps {
        sh '''
          pip install -r app/requirements.txt
          cd app && pytest tests/ -v
        '''
      }
    }

    stage('Build Image') {
      steps {
        sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ./app"
      }
    }

    stage('Push to Registry') {
      steps {
        sh '''
          echo $DOCKERHUB_CRED_PSW | docker login -u $DOCKERHUB_CRED_USR --password-stdin
          docker push ${IMAGE_NAME}:${IMAGE_TAG}
          docker tag  ${IMAGE_NAME}:${IMAGE_TAG} ${IMAGE_NAME}:latest
          docker push ${IMAGE_NAME}:latest
        '''
      }
    }

    stage('Update Manifest') {
      steps {
        sh '''
          git config user.email "jenkins@ci.local"
          git config user.name  "Jenkins"
          sed -i "s|image: ${IMAGE_NAME}:.*|image: ${IMAGE_NAME}:${IMAGE_TAG}|" k8s/deployment.yaml
          git add k8s/deployment.yaml
          git commit -m "ci: bump image to ${IMAGE_TAG}"
          git push https://${GIT_CRED_USR}:${GIT_CRED_PSW}@${GIT_REPO} HEAD:main
        '''
      }
    }
  }

  post {
    failure {
      echo "Pipeline failed — ArgoCD keeps last healthy deployment"
    }
  }
}
