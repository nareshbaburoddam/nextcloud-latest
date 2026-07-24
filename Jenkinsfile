pipeline {
    agent { label 'slave-133' }

    parameters {
        string(name: 'MAJOR', defaultValue: '1', description: 'Major version')
        string(name: 'MINOR', defaultValue: '0', description: 'Minor version')
        string(name: 'PATCH', defaultValue: '0', description: 'Patch version')
        choice(name: 'ENVIRONMENT', choices: ['dev', 'qa', 'prod'], description: 'Target environment')
        booleanParam(name: 'DEPLOY', defaultValue: false, description: 'Deploy after build?')
    }

    environment {
        REGISTRY = 'ghcr.io'
        OWNER = 'nareshbaburoddam'
        IMAGE_NAME = "nextcloud-php-${params.ENVIRONMENT}"
        VERSION = "${params.MAJOR}.${params.MINOR}.${params.PATCH}.${env.BUILD_NUMBER}"
        FULL_IMAGE = "${REGISTRY}/${OWNER}/${IMAGE_NAME}"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Log in to GHCR') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'ghcr-credentials',
                    usernameVariable: 'GHCR_USER',
                    passwordVariable: 'GHCR_TOKEN'
                )]) {
                    sh 'echo $GHCR_TOKEN | docker login ghcr.io -u $GHCR_USER --password-stdin'
                }
            }
        }

        stage('Build Image') {
            steps {
                sh """
                    docker build -t ${FULL_IMAGE}:latest -t ${FULL_IMAGE}:${VERSION} -f ./php/Dockerfile .
                """
            }
        }

        stage('Push Image') {
            steps {
                sh """
                    docker push ${FULL_IMAGE}:latest
                    docker push ${FULL_IMAGE}:${VERSION}
                """
            }
        }

        stage('Cleanup Old Versions') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'ghcr-credentials',
                    usernameVariable: 'GHCR_USER',
                    passwordVariable: 'GHCR_TOKEN'
                )]) {
                    sh """
                        VERSIONS=\$(curl -s -H "Authorization: Bearer \$GHCR_TOKEN" \
                            -H "Accept: application/vnd.github+json" \
                            "https://api.github.com/users/${OWNER}/packages/container/${IMAGE_NAME}/versions?per_page=100")

                        COUNT=\$(echo "\$VERSIONS" | jq 'length')
                        echo "Total versions found: \$COUNT"

                        if [ "\$COUNT" -le 2 ]; then
                            echo "Only \$COUNT versions exist, nothing to delete."
                        else
                            IDS_TO_DELETE=\$(echo "\$VERSIONS" | jq -r 'sort_by(.created_at) | reverse | .[2:] | .[].id')
                            for id in \$IDS_TO_DELETE; do
                                echo "Deleting version id: \$id"
                                curl -s -X DELETE -H "Authorization: Bearer \$GHCR_TOKEN" \
                                    -H "Accept: application/vnd.github+json" \
                                    "https://api.github.com/users/${OWNER}/packages/container/${IMAGE_NAME}/versions/\$id"
                            done
                        fi
                    """
                }
            }
        }

        stage('Approval') {
            when {
                allOf {
                    expression { params.DEPLOY == true }
                    expression { params.ENVIRONMENT == 'prod' }
                }
            }
            steps {
                withCredentials([string(credentialsId: 'teams-webhook-url', variable: 'TEAMS_WEBHOOK')]) {
                    script {
                        def payload = """
                        {
                            "type": "message",
                            "attachments": [
                                {
                                    "contentType": "application/vnd.microsoft.card.adaptive",
                                    "content": {
                                        "type": "AdaptiveCard",
                                        "version": "1.4",
                                        "body": [
                                            {
                                                "type": "TextBlock",
                                                "text": "Approval needed: Deploy ${VERSION} to PRODUCTION",
                                                "weight": "bolder",
                                                "size": "medium"
                                            },
                                            {
                                                "type": "TextBlock",
                                                "text": "Click below to review and approve.",
                                                "wrap": true
                                            }
                                        ],
                                        "actions": [
                                            {
                                                "type": "Action.OpenUrl",
                                                "title": "Review in Jenkins",
                                                "url": "${env.BUILD_URL}"
                                            }
                                        ]
                                    }
                                }
                            ]
                        }
                        """
                        writeFile file: 'teams_payload.json', text: payload
                        sh 'curl -H "Content-Type: application/json" -d @teams_payload.json "$TEAMS_WEBHOOK"'
                    }
                }
                timeout(time: 30, unit: 'MINUTES') {
                    input(
                        message: "Approve deployment of ${VERSION} to PRODUCTION?",
                        ok: 'Deploy',
                        submitter: 'gururaj'
                    )
                }
            }
        }

        stage('Deploy') {
            when {
                expression { params.DEPLOY == true }
            }
            steps {
                sh """
                    export IMAGE_NAME=${FULL_IMAGE}
                    export IMAGE_TAG=${VERSION}
                    docker compose down
                    docker compose pull
                    docker compose up -d
                """
            }
        }

        stage('Verify') {
            when {
                expression { params.DEPLOY == true }
            }
            steps {
                sh '''
                    sleep 10
                    docker ps
                '''
            }
        }
    }

    post {
        success {
            echo "✅ Build ${VERSION} succeeded for ${params.ENVIRONMENT}"
        }
        failure {
            echo "❌ Pipeline failed. Check logs above."
        }
        always {
            sh 'docker logout ghcr.io || true'
        }
    }
}
