properties(
    [
        githubProjectProperty(
            displayName: 'docker-daedalos',
            projectUrlStr: 'https://github.com/ruepp-jenkins/docker-daedalos/'
        ),
        disableConcurrentBuilds()
    ]
)

pipeline {
    agent {
        label 'docker'
    }

    environment {
        IMAGE_FULLNAME = 'ruepp/daedalos'
        DOCKER_API_PASSWORD = credentials('DOCKER_API_PASSWORD')
    }

    triggers {
        URLTrigger(
            cronTabSpec: 'H/30 * * * *',
            entries: [
                URLTriggerEntry(
                    url: 'https://hub.docker.com/v2/namespaces/library/repositories/node/tags/21-alpine',
                    contentTypes: [
                        JsonContent(
                            [
                                JsonContentEntry(jsonPath: '$.last_updated')
                            ]
                        )
                    ]
                ),
                URLTriggerEntry(
                    url: 'https://api.github.com/repos/DustinBrett/daedalOS/commits/main',
                    contentTypes: [
                        JsonContent(
                            [
                                JsonContentEntry(jsonPath: '$.commit.author.date')
                            ]
                        )
                    ]
                )
            ]
        )
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: env.BRANCH_NAME,
                url: env.GIT_URL
            }
        }
        stage('Build') {
            steps {
                sh 'chmod +x scripts/*.sh'
                sh './scripts/start.sh'
            }
        }
    }

    post {
        always {
            discordSend result: currentBuild.currentResult,
                description: env.GIT_URL,
                link: env.BUILD_URL,
                title: JOB_NAME,
                webhookURL: DISCORD_WEBHOOK
            cleanWs()
        }
    }
}
