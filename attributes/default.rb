#
# Cookbook Name:: wl
# Attributes:: default
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

default["wl"]["arch"] = "x86_64"

default["wl"]["database"]["selection"] = "mysql"
default["wl"]["database"]["preinstalled"] = "true"

default["wl"]["mysql"]["host"] = node['ipaddress']
default["wl"]["mysql"]["port"] = 3306
default["wl"]["mysql"]["username"] = "worklight"
default["wl"]["mysql"]["password2"] = "password"
default["wl"]["mysql"]["driver"] = "mysql-connector-java-5.1.25-bin.jar"
default["wl"]["mysql"]["appcenter"]["username"] = "appcenter"
default["wl"]["mysql"]["appcenter"]["password"] = "appcenter"
default["wl"]["mysql"]["appcenter"]["dbname"] = "APPCNTR"

default["wl"]["appserver"]["selection"] = "tomcat"
default["wl"]["tomcat"]["installdir"] = "/usr/local/tomcat/base"
