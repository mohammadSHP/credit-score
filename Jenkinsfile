pipeline {
  agent any

  environment {
    IMAGE_NAME     = "mohammadshp/credit-score"
    IMAGE_TAG      = "${env.BUILD_NUMBER}"
    DOCKERHUB_CRED = credentials('dockerhub-creds')
    GIT_CRED       = credentials('git-creds')
    GIT_REPO       = "github.com/mohammadSHP/credit-score.git"
    DOCKER = "/var/jenkins_home/docker"
    DOCKER_CONFIG  = "/var/jenkins_home/docker-config"
  }

  stages {

    stage('Checkout') {
      steps {
        git branch: 'main',
            credentialsId: 'git-creds',
            url: 'https://github.com/mohammadSHP/credit-score.git'
      }
    }

    stage('Install Docker') {
      steps {
        sh '''
          if [ ! -f /var/jenkins_home/docker ]; then
            curl -fsSL https://download.docker.com/linux/static/stable/x86_64/docker-27.0.3.tgz | \
            tar xz --strip-components=1 -C /tmp docker/docker
            chmod +x /var/jenkins_home/docker
          fi
          mkdir -p $DOCKER_CONFIG
          /var/jenkins_home/docker --version
        '''
      }
    }

    stage('Build & Test Image') {
      steps {
        sh "$DOCKER build -t ${IMAGE_NAME}:${IMAGE_TAG} ./app"
      }
    }

    stage('Push to Registry') {
      steps {
        sh '''
          mkdir -p $DOCKER_CONFIG
          echo $DOCKERHUB_CRED_PSW | $DOCKER --config $DOCKER_CONFIG login -u $DOCKERHUB_CRED_USR --password-stdin
          $DOCKER --config $DOCKER_CONFIG push ${IMAGE_NAME}:${IMAGE_TAG}
          $DOCKER --config $DOCKER_CONFIG tag  ${IMAGE_NAME}:${IMAGE_TAG} ${IMAGE_NAME}:latest
          $DOCKER --config $DOCKER_CONFIG push ${IMAGE_NAME}:latest
        '''
      }
    }

    stage('Update Manifest') {
      steps {
        sh '''
          git config user.email "jenkins@ci.local"
          git config user.name  "Jenkins"
          git checkout main
          sed -i "s|image: ${IMAGE_NAME}:.*|image: ${IMAGE_NAME}:${IMAGE_TAG}|" k8s/deployment.yaml
          git add k8s/deployment.yaml
          git commit -m "ci: bump image to ${IMAGE_TAG}"
          git push https://${GIT_CRED_USR}:${GIT_CRED_PSW}@${GIT_REPO} HEAD:main
        '''
      }
    }
  }

  post {
    success {
      echo "Pipeline succeeded — ArgoCD will deploy image ${IMAGE_TAG}"
    }
    failure {
      echo "Pipeline failed — ArgoCD keeps last healthy deployment"
    }
  }
}
