pipeline {
    tools { 
        maven 'maven3' 
        jdk 'Java11'
    }
    agent { 
        any
    }
    stages {
        stage("Initialize Pipeline") {
            steps {
            	container ('runner') {
	                script {     
                      common.setEnvVars()
	                    def props = readProperties file: 'JenkinsParams'
	                    env.REGISTRY_URL = props['REGISTRY_URL']
	                    env.REGISTRY_NAME = props['REGISTRY_NAME']
	                    env.SLACK_CHANNEL = props['SLACK_CHANNEL']
                        env.SCAN_JAVA_BINARIES = props['SCAN_JAVA_BINARIES']
                        env.SCAN_JAVA_LIBRARIES = props['SCAN_JAVA_LIBRARIES']
	                    def ver_file = readMavenPom file: 'pom.xml'
	                    env.VERSION = ver_file.version
	                    env.DOCKERFILE_PATH = Dockerfile	                   
                 	
                            if ( env.BRANCH_NAME && env.BRANCH_NAME ==~ /(development)/) { 
                                env.TAG_NAME = env.BRANCH_NAME
                            }
	                    }
	                    //Enviar Notificacion a Slack
                        slackNotif.updateStageMessage()
	                }
            	}
            }
        } 

        stage('Build app') {
            steps {
                script {
                    sh 'mvn clean install -U -DskipTests -f pom.xml -s settings.xml'
                }
            }
        }                                
             
        stage('Test') {
            steps {
                script {
                    echo 'Ejecucion de pruebas desabilitado ...'
                    sh 'mvn test'
                }
            }
        }
        
        stage('Escaneos de Seguridad') {
            steps {
                script {
                    slackNotif.initStageMessage()    // Init Stage Slack Message
                  // Codigo para llamada sonar
                    slackNotif.updateStageMessage()  //Update Stage Notificacion
                }
            }
        }
            
        stage('Build Docker Image') {
            steps {
                script {
                    slackNotif.initStageMessage()    // Init Stage Slack Message
                    //Create docker Image
                    sh "DOCKER_BUILDKIT=1  docker build --network=host --file ${env.DOCKERFILE_PATH} -t ${env.REGISTRY_URL}/${env.REGISTRY_NAME}:build_${env.GIT_REPO_NAME}_B${env.BUILD_NUMBER}_C${env.SHORT_COMMIT} ."

                    env.IMAGE_ID = sh returnStdout: true, script: "docker images ${env.REGISTRY_URL}/${env.REGISTRY_NAME}:build_${env.GIT_REPO_NAME}_B${env.BUILD_NUMBER}_C${env.SHORT_COMMIT} -q"
                    
                    // Pushing to ECR Repository
                    
                    sh "docker tag ${env.REGISTRY_URL}/${env.REGISTRY_NAME}:build_${env.GIT_REPO_NAME}_B${env.BUILD_NUMBER}_C${env.SHORT_COMMIT} ${env.REGISTRY_URL}/${env.REGISTRY_NAME}:build_${env.GIT_REPO_NAME}_${env.TAG_NAME}_${env.VERSION}"
                    sh "docker push ${env.REGISTRY_URL}/${env.REGISTRY_NAME}:build_${env.GIT_REPO_NAME}_${env.TAG_NAME}_${env.VERSION}"
                    
                    slackNotif.updateStageMessage()  //Update Stage Notificacion
                }
            }
        }
        stage('DEPLOY'){
            script{
                slackNotif.initStageMessage()    // Init Stage Slack Message
                sh "docker tag ${env.REGISTRY_URL}/${env.REGISTRY_NAME}:build_${env.GIT_REPO_NAME}_B${env.BUILD_NUMBER}_C${env.SHORT_COMMIT} ${env.REGISTRY_URL}/${env.REGISTRY_NAME}:${env.GIT_REPO_NAME}_dev_B${env.BUILD_NUMBER}_C${env.SHORT_COMMIT}"
                sh "docker push ${env.REGISTRY_URL}/${env.REGISTRY_NAME}:${env.GIT_REPO_NAME}_dev_B${env.BUILD_NUMBER}_C${env.SHORT_COMMIT}"
            }
            slackNotif.updateStageMessage()  //Update Stage Notificacion
        }

    
    post {
        always {
            script {
                finalPostActions()
            }
        }
    }
}