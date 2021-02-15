@Library('jenkins-pipeline-library@main') _

pipeline {
  agent {
    node {
      label 'openstack-slave-pangyo'
      customWorkspace "workspace/${env.JOB_NAME}/${env.BUILD_NUMBER}"
    }
  }

  parameters {
    string(name: 'DEPLOY_APPS',
      defaultValue: 'lma',
      description: 'Apps to deploy on k8s cluster(comma-seperated list)'
    )
    booleanParam(name: 'CLEANUP',
      defaultValue: true,
      description: 'delete VM once job is finished?'
    )
  }

  stages {
    stage ('Prepare manifest') {
      steps {
        script {
          sh """
            git clone https://github.com/openinfradev/taco-gate-inventories.git
            cp taco-gate-inventories/config/pangyo-clouds.yml ./clouds.yaml
          """

          vmNamePrefixRand = getK8sVmName("k8s_endpoint")
          vmIPs = getOpenstackVMinfo(vmNamePrefixRand, 'private-mgmt-online', 'openstack-pangyo')
          ceph_mon_host=""

          nodeCount = 0
          def nodeIps = []

          // get API endpoints
          if (vmIPs) {
            vmIPs.eachWithIndex { name, ip, index ->
              nodeCount += 1
              if (index==0) {
                ADMIN_NODE_IP = ip
                print("Found admin node IP: ${ADMIN_NODE_IP}")
              }
              nodeIps[index] = ip
            }
          }

          if (nodeCount == 0) {
            error "No VMs to deploy apps"
          }

          else if (nodeCount == 1) {
            // aio 
            ceph_mon_host=ADMIN_NODE_IP
          } else {
            // multi nodes
            def cephNodes = [nodeIps[0], nodeIps[1], nodeIps[2]]
            ceph_mon_host=cephNodes.join(',')
          }
          BRANCH_NAME = "jenkins-deploy-${env.BUILD_NUMBER}"
          sh """
            git clone https://github.com/openinfradev/decapod-site-yaml.git
            cd decapod-site-yaml && git checkout -b $BRANCH_NAME

            #sed -i 's/TACO_MON_HOST/ceph_mon_host/g' openstack/site/hanu-deploy-apps/*-manifest.yaml
            #git status
            #git commit -a -m "replace TACO_XXX variables" --author="Esther Kim <jabbukka@naver.com>"
            git push origin $BRANCH_NAME
            cd ..
          """
        }
      }
    }
    stage ('Run argo workflow') {
      steps {
        script {

          sh """
            cp /opt/jenkins/.ssh/jenkins-slave-hanukey ./jenkins.key
            scp -o StrictHostKeyChecking=no -i jenkins.key -r taco-gate-inventories/workflows/* taco-gate-inventories/scripts/deployApps.sh taco@$ADMIN_NODE_IP:/home/taco/
            ssh -o StrictHostKeyChecking=no -i jenkins.key taco@$ADMIN_NODE_IP chmod 0755 /home/taco/deployApps.sh
            ssh -o StrictHostKeyChecking=no -i jenkins.key taco@$ADMIN_NODE_IP /home/taco/deployApps.sh --apps ${params.DEPLOY_APPS} --site hanu-deploy-apps --branch jenkins 
            # To be fixed: $BRANCH_NAME
          """
        }
      }
    }
  }
  post {
    always {
      script {
        sh """
          echo "Delete temporary branch"
          cd hanu-site-yaml && git push origin :$BRANCH_NAME
        """
      }
    }
    success {
      script {
        if ( params.CLEANUP == true ) {
          deleteOpenstackVMs(vmNamePrefix, nameKey, 'openstack-pangyo')
        } else {
          echo "Skipping VM cleanup.."
        }
      }
    }
  }
}
