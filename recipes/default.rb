#
# Cookbook Name:: wl
# Recipe:: default
#
# Copyright 2013, kangaechu.com
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

filenameInstMgr = "agent.installer.linux.gtk.x86_64_1.6.3001.20130528_1750.zip"
filenameWLServer = "CIN04EN_001.zip"
InstallPackageDir = "/tmp/tools"
InstallationManagerExtractDir = "InstallationManager"

package "unzip" do
  action :install
end

bash "Install Installation Manager" do
  user "root"
  cwd "/tmp"
  flags "-x -e"
  code <<-EOH
    INSTDATE=`date "+%Y%m%d-%H%M"`
    rm -rf /tmp/#{InstallationManagerExtractDir}
    mkdir #{InstallationManagerExtractDir}
    unzip -q #{InstallPackageDir}/#{filenameInstMgr} -d #{InstallationManagerExtractDir}
    cd #{InstallationManagerExtractDir}
    ./install --launcher.ini silent-install.ini -log /tmp/InstallationManager-${INSTDATE}.log -acceptLicense
    rm -rf /tmp/#{filenameInstMgr.sub(".zip", "")}
  EOH
  not_if {File.exists?("/opt/IBM/InstallationManager")}
end

template "/tmp/responseFile.xml" do
  source "responseFile.xml.erb"
  owner "root"
  group "root"
  mode "0644"
end

execute "wl-createdb-mysql" do
  command "/usr/bin/mysql -u root -p\"#{node['mysql']['server_root_password']}\" < #{node['mysql']['conf_dir']}/wl-createdb-mysql.sql"
  action :nothing
end

template "#{node['mysql']['conf_dir']}/wl-createdb-mysql.sql" do
  source "createdb-mysql.sql.erb"
  owner "root"
  group "root"
  mode "0644"
  not_if {File.exists?("/opt/IBM/Worklight")}
  notifies :run, "execute[wl-createdb-mysql]", :immediately
end

bash "wl-createtables-mysql" do
  code <<-EOH
    /usr/bin/mysql -u root -p\"#{node['mysql']['server_root_password']}\" WRKLGHT < /opt/IBM/Worklight/WorklightServer/databases/create-worklight-mysql.sql
    /usr/bin/mysql -u root -p\"#{node['mysql']['server_root_password']}\" WLREPORT < /opt/IBM/Worklight/WorklightServer/databases/create-worklightreports-mysql.sql
  EOH
  action :nothing
end

bash "Install Worklight Server" do
  user "root"
  cwd "/tmp"
  flags "-x -e"
  code <<-EOH
    INSTDATE=`date "+%Y%m%d-%H%M"`
    cp -f #{InstallPackageDir}/#{node[:wl][:mysql][:driver]} /tmp
    rm -rf /tmp/Worklight
    unzip -q #{InstallPackageDir}/#{filenameWLServer}
    cd /opt/IBM/InstallationManager/eclipse
    ./IBMIM --launcher.ini silent-install.ini -input /tmp/responseFile.xml -log /tmp/WLServer-${INSTDATE}.xml -acceptLicense
    cp /opt/IBM/Worklight/WorklightServer/worklight-jee-library.jar #{node[:wl][:tomcat][:installdir]}/lib/
    rm -rf /tmp/Worklight
    rm /tmp/#{node[:wl][:mysql][:driver]}
  EOH
  not_if {File.exists?("/opt/IBM/Worklight")}
  notifies :run, "bash[wl-createtables-mysql]", :immediately
end

template "#{node[:wl][:tomcat][:installdir]}/conf/Catalina/localhost/worklight.xml" do
  source "worklight.xml.erb"
  owner "tomcat"
  group "tomcat"
  mode "0644"
end

directory "#{node[:wl][:tomcat][:installdir]}/webapps/worklight" do
  owner "tomcat"
  group "tomcat"
  mode "0755"
  action :create
end
