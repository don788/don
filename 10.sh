node ("slave1-10.0.0.173"){
   stage('checkout') { // for display purposes
		checkout([$class: 'GitSCM', branches: [[name: '*/master']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [],
userRemoteConfigs: [[url: 'git@10.0.0.172:/home/git/repos/app.git']]])
   }
   stage('code copy') {
		 sh '''rm -rf ${WORKSPACE}/.git
        mv /usr/share/nginx/html/test.zhangcaiwang.com /data/backup/test.zhangcaiwang.com-$(date +"%F_%T")
        cp -rf ${WORKSPACE} /usr/share/nginx/html/test.zhangcaiwang.com'''
   }
   stage('test'){
		sh "curl http://test.zhangcaiwang.com/status.html"
	}
}




node ("slave1-192.168.0.215") {
   stage('git checkout') { 
       checkout([$class: 'GitSCM', branches: [[name: '${branch}']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[url: 'git@192.168.0.216:/home/git/repos/wordpress']]])
   }
   stage('code copy') {
        sh '''rm -rf ${WORKSPACE}/.git
        mv /usr/share/nginx/html/wp.aliangedu.com /data/backup/wp.aliangedu.com-$(date +"%F_%T")
        cp -rf ${WORKSPACE} /usr/share/nginx/html/wp.aliangedu.com'''
   }
   stage('test') {
       sh "curl http://wp.aliangedu.com/status.html"
   }
}