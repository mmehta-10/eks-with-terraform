// Assumes installation of kubernetes-cli-plugin on Jenkins master - https://plugins.jenkins.io/kubernetes-cli/

node {
  stage('Deploy to stage') {
      try{
        withKubeConfig([credentialsId: '<credential-id>',
                        caCertificate: '<ca-certificate>',
                        serverUrl: '<api-server-address>',
                        contextName: '<context-name>',
                        clusterName: '<cluster-name>',
                        namespace: '<namespace>'
                        ]) {
            sh 'kubectl apply -f kubernetes/max-weather.yaml'
            // Wait for deployment to succeed
            sh 'kubectl rollout status deploy/max-weather-forecaster'
        }
      } catch(err){
          echo "Error: " + err.toString()
          throw
      }
  }

    stage('Acceptance tests') {
        echo 'Stage to run tests for verifying deployment'
    }

    stage('Deploy to prod') {
       try{
        withKubeConfig([credentialsId: '<credential-id>',
                        caCertificate: '<ca-certificate>',
                        serverUrl: '<api-server-address>',
                        contextName: '<context-name>',
                        clusterName: '<cluster-name>',
                        namespace: '<namespace>'
                        ]) {
            sh 'kubectl apply -f kubernetes/max-weather.yaml'
            // Wait for deployment to succeed
            sh 'kubectl rollout status deploy/max-weather-forecaster'
        }
      } catch(err){
          echo "Error: " + err.toString()
          throw
      }
    }
}