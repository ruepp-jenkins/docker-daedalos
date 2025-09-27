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
        DEPENDENCYTRACK_HOST = 'http://172.20.89.2:8080'
        DEPENDENCYTRACK_API_TOKEN = credentials('dependencychecker')
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
            steps {
                git branch: env.BRANCH_NAME,
                url: env.GIT_URL
            }
        }
        stage('Clone and YARN') {
            steps {
                sh 'chmod u+x scripts/git.sh'
                sh 'scripts/git.sh'
                sh "docker run --rm -v /opt/docker/jenkins/jenkins_ws:/home/jenkins/workspace -w ${WORKSPACE}/repo/ node:lts sh ${WORKSPACE}/dependency_check.sh"
            }
        }
        stage('DependencyTracker') {
            steps {
                script {
                    // root project body
                    def body = groovy.json.JsonOutput.toJson([
                        name: "${env.JOB_NAME}",
                        classifier: "NONE",
                        collectionLogic: "AGGREGATE_LATEST_VERSION_CHILDREN"
                    ])

                    // create root project
                    httpRequest contentType: 'APPLICATION_JSON',
                        httpMode: 'PUT',
                        customHeaders: [
                            [name: 'X-Api-Key', value: env.DEPENDENCYTRACK_API_TOKEN, maskValue: true]
                        ],
                        requestBody: body,
                        url: "${DEPENDENCYTRACK_HOST}/api/v1/project",
                        validResponseCodes: '200:299,409' // 409: project already exist
                }

                sh "docker run --rm -v /opt/docker/jenkins/jenkins_ws:/home/jenkins/workspace cyclonedx/cyclonedx-node -o ${WORKSPACE}/bom.xml ${WORKSPACE}/repo"

                dependencyTrackPublisher(
                    artifact: 'bom.xml',
                    projectName: env.JOB_NAME,
                    projectVersion: env.BUILD_NUMBER,
                    synchronous: false,
                    projectProperties: [
                        isLatest: true,
                        parentName: env.JOB_NAME,
                        tags: ['image', 'yarn']
                    ]
                )
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
