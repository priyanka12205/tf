node {
    stage('Create Sample File') {
        bat 'echo Hello S3 from Jenkins > sample_priyanka.txt'
    }

    stage('Upload to S3') {
        bat 'aws s3 cp sample_priyanka.txt s3://prj3/'
    }
}
