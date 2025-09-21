properties(
    [
        githubProjectProperty(
            displayName: 'docker-daedalos',
            projectUrlStr: 'https://github.com/ruepp-jenkins/docker-daedalos/'
        ),
        disableConcurrentBuilds(abortPrevious: true)
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
                    url: 'https://hub.docker.com/v2/namespaces/library/repositories/node/tags/22-alpine',
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
            cleanWs()
            steps {
                git branch: env.BRANCH_NAME,
                url: env.GIT_URL
            }
        }
        stage('Clone and YARN') {
            steps {
                sh 'chmod u+x scripts/git.sh'
                sh 'scripts/git.sh'
                sh "docker run --rm -v /opt/docker/jenkins/jenkins_ws:/home/jenkins/workspace -w ${WORKSPACE} node:lts cd ${WORKSPACE}/dependency_check.sh"
            }
        }
        stage('DependencyTracker') {
            steps {
                sh "docker run --rm -v /opt/docker/jenkins/jenkins_ws:/home/jenkins/workspace ubuntu ls -lah ${WORKSPACE}"
                sh "docker run --rm -v /opt/docker/jenkins/jenkins_ws:/home/jenkins/workspace ubuntu ls -lah ${WORKSPACE}/repo"
                sh "docker run --rm -v /opt/docker/jenkins/jenkins_ws:/home/jenkins/workspace cyclonedx/cyclonedx-node -o ${WORKSPACE} ${WORKSPACE}/repo"
                dependencyTrackPublisher artifact: 'bom.xml', projectName: env.JOB_NAME, projectVersion: env.BUILD_NUMBER, synchronous: true
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
            // cleanWs()
        }
    }
}
