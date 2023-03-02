sleep 30
sudo yum update -y
sudo yum install java-11-openjdk.x86_64 -y
suod yum install unzip -y
sudo yum install wget -y
sudo mkdir /var/opt/sworks

# Datadog Agent Install
echo "Adding datadog agent..."
sudo DD_AGENT_MAJOR_VERSION=7 DD_API_KEY=ab44lja555lkj666lkj66lkj6 DD_LOGS_ENABLED=true DD_COLLECT_EC2_TAGS=true DD_SITE="datadoghq.com" bash -c "$(curl -L https://s3.amazonaws.com/dd-agent/scripts/install_script.sh)"

#echo "Adding datadog agent to sonar group to read logs..."
#sudo usermod -a -G sonarqube dd-agent

#echo "Adding DD configs..."
#sudo mv /tmp/datadog.yaml /etc/datadog-agent/

# MicrosoftDefender install
echo "Adding MSDATP.."
curl "https://nexus.aws.sworks.com/repository/thirdparty-artifacts/MicrosoftDefenderATPOnboardingLinuxServer/MicrosoftDefenderATPOnboardingLinuxServer.py" > /tmp/MicrosoftDefenderATPOnboardingLinuxServer.py
curl "https://raw.githubusercontent.com/microsoft/mdatp-xplat/master/linux/installation/mde_installer.sh" > /tmp/mde_installer.sh
chmod +x /tmp/mde_installer.sh
sudo /tmp/mde_installer.sh --install --channel prod --onboard /tmp/MicrosoftDefenderATPOnboardingLinuxServer.py --min_req -y

# Qualys Agent install
echo "Adding Qualys Agent..."
wget -q -P /tmp/qualys-cloud-agent "https://nexus.aws.secureworks.com/repository/toolbox/7/ct3-qualys-cloud-agent-0.1.1-2.el7.x86_64.rpm"
wget -q -P /tmp/qualys-cloud-agent "https://nexus.aws.secureworks.com/repository/toolbox/7/QualysCloudAgent.rpm"
sudo rpm -ivh /tmp/qualys-cloud-agent/*.rpm
sudo /usr/libexec/ct3-qualys-cloud-agent/activate-qualys-agent.sh

echo "Cleaning up cloud-init data..."
sudo rm -rf /var/lib/cloud/instance*