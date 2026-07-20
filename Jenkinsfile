pipeline {
    // Run this pipeline on the slave node with this label
    // (Set the label under: Manage Jenkins > Nodes > <your node> > Labels)
    agent { label 'slave-133' }

    parameters {
        string(name: 'GIT_REPO', defaultValue: 'https://github.com/nareshbaburoddam/nextcloud-latest.git', description: 'GitHub repo URL')
        string(name: 'GIT_BRANCH', defaultValue: 'main', description: 'Branch to build')
        string(name: 'COMPOSE_FILE', defaultValue: 'docker-compose.yml', description: 'Path to compose file inside the repo')
    }

    options {
        timestamps()
        disableConcurrentBuilds()
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: "${params.GIT_BRANCH}",
                    url: "${params.GIT_REPO}",
                    credentialsId: 'nareshbaburoddam-git-creds'
                    // 'nareshbaburoddam-git-creds' must match the ID of the credential you
                    // added under Manage Jenkins > Credentials
            }
        }

        stage('Verify Tools') {
            steps {
                sh 'docker --version'
                sh 'docker compose version || docker-compose --version'
            }
        }

        stage('Compose Up') {
            steps {
                sh "docker compose -f ${params.COMPOSE_FILE} up -d --build"
            }
        }

        stage('Status') {
            steps {
                sh "docker compose -f ${params.COMPOSE_FILE} ps"
            }
        }
    }

    post {
        failure {
            echo 'Pipeline failed — tearing down any partially started containers.'
            sh "docker compose -f ${params.COMPOSE_FILE} down || true"
        }
        always {
            echo "Build finished with status: ${currentBuild.currentResult}"
        }
    }
}
