# escape=`

# The MIT License
#
#  Copyright (c) 2020, Alex Earl and other Jenkins Contributors
#
#  Permission is hereby granted, free of charge, to any person obtaining a copy
#  of this software and associated documentation files (the "Software"), to deal
#  in the Software without restriction, including without limitation the rights
#  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#  copies of the Software, and to permit persons to whom the Software is
#  furnished to do so, subject to the following conditions:
#
#  The above copyright notice and this permission notice shall be included in
#  all copies or substantial portions of the Software.
#
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#  THE SOFTWARE.

# Args used by from statements must be defined here:
ARG InstallerVersion=nanoserver
ARG dockerHost=mcr.microsoft.com
ARG InstallerRepo=mcr.microsoft.com/powershell
ARG NanoServerRepo=windows/nanoserver
ARG tag=ltsc2022

# Use server core as an installer container to extract PowerShell,
# As this is a multi-stage build, this stage will eventually be thrown away
FROM ${InstallerRepo}:$InstallerVersion  AS installer-env

# Arguments for installing PowerShell, must be defined in the container they are used
ARG PS_VERSION=7.0.0

ARG PS_PACKAGE_URL=https://github.com/PowerShell/PowerShell/releases/download/v$PS_VERSION/PowerShell-$PS_VERSION-win-x64.zip

SHELL ["pwsh", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# disable telemetry
ENV POWERSHELL_TELEMETRY_OPTOUT="1"

ARG PS_PACKAGE_URL_BASE64

RUN Write-host "Verifying valid Version..."; `
    if (!($env:PS_VERSION -match '^\d+\.\d+\.\d+(-\w+(\.\d+)?)?$' )) { `
        throw ('PS_Version ({0}) must match the regex "^\d+\.\d+\.\d+(-\w+(\.\d+)?)?$"' -f $env:PS_VERSION) `
    } `
    $ProgressPreference = 'SilentlyContinue'; `
    if($env:PS_PACKAGE_URL_BASE64){ `
        Write-host "decoding: $env:PS_PACKAGE_URL_BASE64" ;`
        $url = [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($env:PS_PACKAGE_URL_BASE64)) `
    } else { `
        Write-host "using url: $env:PS_PACKAGE_URL" ;`
        $url = $env:PS_PACKAGE_URL `
    } `
    Write-host "downloading: $url"; `
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12; `
    New-Item -ItemType Directory /installer > $null ; `
    Invoke-WebRequest -Uri $url -outfile /installer/powershell.zip -verbose; `
    Expand-Archive /installer/powershell.zip -DestinationPath \PowerShell

# Install PowerShell into NanoServer
FROM mcr.microsoft.com/${NanoServerRepo}:${tag} as pwsh-source

# Copy PowerShell Core from the installer container
ENV ProgramFiles="C:\Program Files" `
    # set a fixed location for the Module analysis cache
    PSModuleAnalysisCachePath="C:\Users\Public\AppData\Local\Microsoft\Windows\PowerShell\docker\ModuleAnalysisCache" `
    # Persist %PSCORE% ENV variable for user convenience
    PSCORE="$ProgramFiles\PowerShell\pwsh.exe" `
    # Set the default windows path so we can use it
    WindowsPATH="C:\Windows\system32;C:\Windows" `
    POWERSHELL_DISTRIBUTION_CHANNEL="PSDocker-NanoServer-ltsc2022"

### Begin workaround ###
# Note that changing user on nanoserver is not recommended
# See, https://docs.microsoft.com/en-us/virtualization/windowscontainers/manage-containers/container-base-images#base-image-differences
# But we are working around a bug introduced in the nanoserver image introduced in 1809
# Without this, PowerShell Direct will fail
# this command sholud be like this: https://github.com/PowerShell/PowerShell-Docker/blob/f81009c42c96af46aef81eb1515efae0ef29ad5f/release/preview/nanoserver/docker/Dockerfile#L76
USER ContainerAdministrator

# This is basically the correct code except for the /M
RUN setx PATH "%PATH%;%ProgramFiles%\PowerShell;" /M

USER ContainerUser
### End workaround ###

COPY --from=installer-env ["\\PowerShell\\", "$ProgramFiles\\PowerShell"]

# intialize powershell module cache
RUN pwsh `
        -NoLogo `
        -NoProfile `
        -Command " `
          $stopTime = (get-date).AddMinutes(15); `
          $ErrorActionPreference = 'Stop' ; `
          $ProgressPreference = 'SilentlyContinue' ; `
          while(!(Test-Path -Path $env:PSModuleAnalysisCachePath)) {  `
            Write-Host "'Waiting for $env:PSModuleAnalysisCachePath'" ; `
            if((get-date) -gt $stopTime) { throw 'timout expired'} `
            Start-Sleep -Seconds 6 ; `
          }"

ARG WINDOWS_VERSION_TAG=ltsc2019
# ARG TOOLS_WINDOWS_VERSION=1809
FROM mcr.microsoft.com/windows/servercore:"${WINDOWS_VERSION_TAG}" AS jdk-core

# $ProgressPreference: https://github.com/PowerShell/PowerShell/issues/2138#issuecomment-251261324
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

ARG JAVA_VERSION=17.0.17+10
RUN New-Item -ItemType Directory -Path C:\temp | Out-Null ; `
    $javaMajorVersion = $env:JAVA_VERSION.substring(0,2) ; `
    $msiUrl = 'https://api.adoptium.net/v3/installer/version/jdk-{0}/windows/x64/jdk/hotspot/normal/eclipse?project=jdk' -f $env:JAVA_VERSION ; `
    Invoke-WebRequest $msiUrl -OutFile 'C:\temp\jdk.msi' ; `
    $proc = Start-Process -FilePath 'msiexec.exe' -ArgumentList '/i', 'C:\temp\jdk.msi', '/L*V', 'C:\temp\OpenJDK.log', '/quiet', 'ADDLOCAL=FeatureEnvironment,FeatureJarFileRunWith,FeatureJavaHome',  "INSTALLDIR=C:\openjdk-${javaMajorVersion}" -Wait -Passthru ; `
    $proc.WaitForExit() ; `
    Remove-Item -Path C:\temp -Recurse | Out-Null

#### MIX START
## Agent image target
FROM mcr.microsoft.com/windows/nanoserver:"${WINDOWS_VERSION_TAG}" AS agent

ARG JAVA_HOME="C:\openjdk-17"
ENV PSHOME="C:\Program Files\PowerShell"
ENV PATH="C:\Windows\system32;C:\Windows;${PSHOME};"

# The nanoserver image is nice and small, but we need a couple of things to get SSH working
COPY --from=jdk-core /windows/system32/netapi32.dll /windows/system32/netapi32.dll
COPY --from=jdk-core /windows/system32/whoami.exe /windows/system32/whoami.exe
COPY --from=jdk-core $JAVA_HOME $JAVA_HOME
COPY --from=pwsh-source $PSHOME $PSHOME

SHELL ["pwsh.exe", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]
USER ContainerAdministrator

ARG GIT_VERSION=2.52.0
ARG GIT_PATCH_VERSION=1
RUN [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 ; `
    # The patch "windows.1" always have a different URL than the subsequent patch (ZIP filename is different)
    if($env:GIT_PATCH_VERSION -eq 1) { $url = $('https://github.com/git-for-windows/git/releases/download/v{0}.windows.{1}/MinGit-{0}-64-bit.zip' -f $env:GIT_VERSION, $env:GIT_PATCH_VERSION); } `
    else {$url = $('https://github.com/git-for-windows/git/releases/download/v{0}.windows.{1}/MinGit-{0}.{1}-64-bit.zip' -f $env:GIT_VERSION, $env:GIT_PATCH_VERSION)} ; `
    Write-Host "Retrieving $url..." ; `
    Invoke-WebRequest $url -OutFile 'mingit.zip' -UseBasicParsing ; `
    Expand-Archive mingit.zip -DestinationPath c:\mingit ; `
    Remove-Item mingit.zip -Force

ENV ProgramFiles="C:\Program Files" `
    WindowsPATH="C:\Windows\system32;C:\Windows" `
    JAVA_HOME="${JAVA_HOME}"
ENV PATH="${WindowsPATH};${ProgramFiles}\PowerShell;${JAVA_HOME}\bin;C:\mingit\cmd"

ARG GIT_LFS_VERSION=3.7.1
RUN [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 ; `
    $url = $('https://github.com/git-lfs/git-lfs/releases/download/v{0}/git-lfs-windows-amd64-v{0}.zip' -f $env:GIT_LFS_VERSION) ; `
    Write-Host "Retrieving $url..." ; `
    Invoke-WebRequest $url -OutFile 'GitLfs.zip' -UseBasicParsing ; `
    Expand-Archive GitLfs.zip -DestinationPath c:\mingit\mingw64\bin ; `
    $gitLfsFolder = 'c:\mingit\mingw64\bin\git-lfs-{0}' -f $env:GIT_LFS_VERSION ; `
    Move-Item -Path "${gitLfsFolder}\git-lfs.exe" -Destination c:\mingit\mingw64\bin\ ; `
    Remove-Item -Path $gitLfsFolder -Recurse -Force ; `
    Remove-Item GitLfs.zip -Force ; `
    & c:\mingit\mingw64\bin\git-lfs.exe install

ARG user=jenkins

ARG AGENT_FILENAME=agent.jar
ARG AGENT_HASH_FILENAME=$AGENT_FILENAME.sha1

RUN net accounts /maxpwage:unlimited ; `
    net user "$env:USER" /add /expire:never /passwordreq:no ; `
    net localgroup Administrators /add $env:USER ; `
    New-Item -ItemType Directory -Path C:/ProgramData/Jenkins | Out-Null

ARG AGENT_ROOT=C:/Users/$user
ARG AGENT_WORKDIR=${AGENT_ROOT}/Work

ENV AGENT_WORKDIR=${AGENT_WORKDIR}

# Get the Agent from the Jenkins Artifacts Repository
ARG VERSION=3355.v388858a_47b_33
RUN [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 ; `
    Invoke-WebRequest $('https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/{0}/remoting-{0}.jar' -f $env:VERSION) -OutFile $(Join-Path C:/ProgramData/Jenkins $env:AGENT_FILENAME) -UseBasicParsing ; `
    Invoke-WebRequest $('https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/{0}/remoting-{0}.jar.sha1' -f $env:VERSION) -OutFile (Join-Path C:/ProgramData/Jenkins $env:AGENT_HASH_FILENAME) -UseBasicParsing ; `
    if ((Get-FileHash (Join-Path C:/ProgramData/Jenkins $env:AGENT_FILENAME) -Algorithm SHA1).Hash -ne (Get-Content (Join-Path C:/ProgramData/Jenkins $env:AGENT_HASH_FILENAME))) {exit 1} ; `
    Remove-Item -Force (Join-Path C:/ProgramData/Jenkins $env:AGENT_HASH_FILENAME)

USER $user

RUN New-Item -Type Directory $('{0}/.jenkins' -f $env:AGENT_ROOT) | Out-Null ; `
    New-Item -Type Directory $env:AGENT_WORKDIR | Out-Null

RUN git config --system core.longpaths true ; `
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem' -Name LongPathsEnabled -type DWord -Value 1

VOLUME "${AGENT_ROOT}"/.jenkins
VOLUME "${AGENT_WORKDIR}"
WORKDIR "${AGENT_ROOT}"
ENV USER=${user}
LABEL `
    org.opencontainers.image.vendor="Jenkins project" `
    org.opencontainers.image.title="Official Jenkins Agent Base Docker image" `
    org.opencontainers.image.description="This is a base image, which provides the Jenkins agent executable (agent.jar)" `
    org.opencontainers.image.version="${VERSION}" `
    org.opencontainers.image.url="https://www.jenkins.io/" `
    org.opencontainers.image.source="https://github.com/jenkinsci/docker-agent" `
    org.opencontainers.image.licenses="MIT"

## Inbound Agent image target
FROM agent AS inbound-agent

COPY jenkins-agent.ps1 C:/ProgramData/Jenkins

LABEL `
    org.opencontainers.image.vendor="Jenkins project" `
    org.opencontainers.image.title="Official Jenkins Inbound Agent Base Docker image" `
    org.opencontainers.image.description="This is an image for Jenkins agents using TCP or WebSockets to establish inbound connection to the Jenkins controller" `
    org.opencontainers.image.version="${VERSION}" `
    org.opencontainers.image.url="https://www.jenkins.io/" `
    org.opencontainers.image.source="https://github.com/jenkinsci/docker-agent" `
    org.opencontainers.image.licenses="MIT"

ENTRYPOINT ["pwsh.exe", "-f", "C:/ProgramData/Jenkins/jenkins-agent.ps1"]

# ###### BEFORE
# # # Download and install PowerShell 7
# # ARG POWERSHELL_VERSION=7.5.4
# # ENV POWERSHELL_VERSION=${POWERSHELL_VERSION}
# # ENV PATH="C:\Windows\system32;C:\Windows;C:\Program Files\Powershell;"
# # RUN curl.exe --silent --location "https://github.com/PowerShell/PowerShell/releases/download/v%POWERSHELL_VERSION%/PowerShell-%POWERSHELL_VERSION%-win-x64.zip" --output C:/windows/TEMP/pwsh.zip `
# # && mkdir "C:\Program Files\Powershell" `
# # && tar.exe -xf C:\windows\TEMP\pwsh.zip -C "C:\Program Files\Powershell" `
# # && if exist "C:\windows\TEMP\pwsh.zip" del "C:\windows\TEMP\pwsh.zip"

# # Download PowerShell 7
# ARG POWERSHELL_VERSION=7.5.4
# ENV POWERSHELL_VERSION=${POWERSHELL_VERSION}
# # Using $env:ProgramFile\Powershell7 for best results
# # Ref: https://learn.microsoft.com/en-us/powershell/scripting/install/install-powershell-on-windows?view=powershell-7.5#install-from-the-zip-package
# ARG PSHOME="C:\Program Files\PowerShell"
# RUN New-Item -ItemType Directory -Path 'C:\temp' | Out-Null ; `
#     $pwshUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v{0}/PowerShell-{0}-win-x64.zip' -f $env:POWERSHELL_VERSION ; `
#     Invoke-WebRequest $pwshUrl -OutFile 'C:\temp\pwsh.zip' ; `
#     Expand-Archive -Path 'C:\temp\pwsh.zip' -DestinationPath 'C:\temp' ; `
#     Remove-Item -Path 'C:\temp\pwsh.zip' | Out-Null

# RUN if (Test-Path $('C:\temp\pwsh.exe')) { Write-Host "File exists." } else { throw "File does not exist." }

# ## Agent image target
# FROM mcr.microsoft.com/windows/nanoserver:"${WINDOWS_VERSION_TAG}" AS agent

# SHELL ["cmd.exe", "/c"]

# ARG JAVA_HOME="C:\openjdk-17"
# ENV PSHOME=${PSHOME}

# # Windows Server Core doesn't allow copying from C:\Program Files\
# COPY --from=jdk-core /temp /temp

# RUN SET
# RUN dir C:
# RUN cd
# # OK \o/
# RUN dir temp
# RUN dir C:\Windows
# RUN echo %PSHOME%

# # RUN move C:\temp\* "C:\Program Files\PowerShell" && rmdir C:\temp
# # RUN move C:\temp\* "C:\Program Files\PowerShell"
# RUN xcopy "C:\temp" "C:\Program Files\PowerShell" /E /I /H /Y

# # RUN robocopy "C:\temp" "%PSHOME%" /E /MOVE /COPYALL && rmdir "C:\temp"
# # RUN robocopy "C:\temp" %PSHOME% /E /MOVE /COPYALL && rmdir "C:\temp"
# # RUN move C:\temp\* %PSHOME%
# # RUN move C:\temp\* "C:\Program Files\PowerShell"

# ENV PATH="C:\Windows\system32;C:\Windows;C:\Program Files\PowerShell;"

# # The nanoserver image is nice and small, but we need a couple of things to get SSH working
# COPY --from=jdk-core /windows/system32/netapi32.dll /windows/system32/netapi32.dll
# COPY --from=jdk-core /windows/system32/whoami.exe /windows/system32/whoami.exe
# COPY --from=jdk-core /windows/system32/icacls.exe /windows/system32/icacls.exe
# COPY --from=jdk-core $JAVA_HOME $JAVA_HOME
# # COPY --from=pwsh-source $PSHOME $PSHOME

# SHELL ["pwsh.exe", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]
# USER ContainerAdministrator

# RUN Write-Output "ARE WE THERE YET?"
# RUN Write-Output "ARE WE THERE YET again?"
# RUN Write-Output $env:PSHOME
# RUN Get-ChildItem env: | ConvertTo-Json

# ARG GIT_VERSION=2.52.0
# ARG GIT_PATCH_VERSION=1
# RUN [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 ; `
#     # The patch "windows.1" always have a different URL than the subsequent patch (ZIP filename is different)
#     if($env:GIT_PATCH_VERSION -eq 1) { $url = $('https://github.com/git-for-windows/git/releases/download/v{0}.windows.{1}/MinGit-{0}-64-bit.zip' -f $env:GIT_VERSION, $env:GIT_PATCH_VERSION); } `
#     else {$url = $('https://github.com/git-for-windows/git/releases/download/v{0}.windows.{1}/MinGit-{0}.{1}-64-bit.zip' -f $env:GIT_VERSION, $env:GIT_PATCH_VERSION)} ; `
#     Write-Host "Retrieving $url..." ; `
#     Invoke-WebRequest $url -OutFile 'mingit.zip' -UseBasicParsing ; `
#     Expand-Archive mingit.zip -DestinationPath c:\mingit ; `
#     Remove-Item mingit.zip -Force

# ENV ProgramFiles="C:\Program Files" `
#     WindowsPATH="C:\Windows\system32;C:\Windows" `
#     JAVA_HOME="${JAVA_HOME}"
# ENV PATH="${PATH};${WindowsPATH};${PSHOME};${JAVA_HOME}\bin;C:\mingit\cmd"
# RUN Get-ChildItem env:PATH | ConvertTo-Json -Depth 1

# ARG GIT_LFS_VERSION=3.7.1
# RUN [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 ; `
#     $url = $('https://github.com/git-lfs/git-lfs/releases/download/v{0}/git-lfs-windows-amd64-v{0}.zip' -f $env:GIT_LFS_VERSION) ; `
#     Write-Host "Retrieving $url..." ; `
#     Invoke-WebRequest $url -OutFile 'GitLfs.zip' -UseBasicParsing ; `
#     Expand-Archive GitLfs.zip -DestinationPath c:\mingit\mingw64\bin ; `
#     $gitLfsFolder = 'c:\mingit\mingw64\bin\git-lfs-{0}' -f $env:GIT_LFS_VERSION ; `
#     Move-Item -Path "${gitLfsFolder}\git-lfs.exe" -Destination c:\mingit\mingw64\bin\ ; `
#     Remove-Item -Path $gitLfsFolder -Recurse -Force ; `
#     Remove-Item GitLfs.zip -Force ; `
#     & c:\mingit\mingw64\bin\git-lfs.exe install

# ARG IMAGE_USER=jenkins
# ENV USER=${IMAGE_USER}

# ARG AGENT_FILENAME=agent.jar
# ARG AGENT_HASH_FILENAME=$AGENT_FILENAME.sha1

# RUN Get-ChildItem env: | ConvertTo-Json

# RUN net accounts /maxpwage:unlimited ; `
#     net user "$env:USER" /add /expire:never /passwordreq:no ; `
#     net localgroup Administrators /add $env:USER ; `
#     New-Item -ItemType Directory -Path C:/ProgramData/Jenkins | Out-Null


# ARG AGENT_ROOT=C:/Users/$IMAGE_USER
# ARG AGENT_WORKDIR=${AGENT_ROOT}/Work

# ENV AGENT_WORKDIR=${AGENT_WORKDIR}

# RUN Get-ChildItem env: | ConvertTo-Json

# # Get the Agent from the Jenkins Artifacts Repository
# ARG VERSION=3355.v388858a_47b_33
# RUN [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 ; `
#     Invoke-WebRequest $('https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/{0}/remoting-{0}.jar' -f $env:VERSION) -OutFile $(Join-Path C:/ProgramData/Jenkins $env:AGENT_FILENAME) -UseBasicParsing ; `
#     Invoke-WebRequest $('https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/{0}/remoting-{0}.jar.sha1' -f $env:VERSION) -OutFile (Join-Path C:/ProgramData/Jenkins $env:AGENT_HASH_FILENAME) -UseBasicParsing ; `
#     if ((Get-FileHash (Join-Path C:/ProgramData/Jenkins $env:AGENT_FILENAME) -Algorithm SHA1).Hash -ne (Get-Content (Join-Path C:/ProgramData/Jenkins $env:AGENT_HASH_FILENAME))) {exit 1} ; `
#     Remove-Item -Force (Join-Path C:/ProgramData/Jenkins $env:AGENT_HASH_FILENAME)

# # Create user home directory and register profile with Windows
# RUN $profilePath = $env:AGENT_ROOT ; `
#     New-Item -Type Directory -Path $profilePath -Force | Out-Null ; `
#     New-Item -Type Directory -Path $('{0}/.jenkins' -f $profilePath) -Force | Out-Null ; `
#     New-Item -Type Directory -Path $env:AGENT_WORKDIR -Force | Out-Null ; `
#     icacls $profilePath /grant ('{0}:(OI)(CI)F' -f $env:USER) /T ; `
#     $userAccount = New-Object System.Security.Principal.NTAccount($env:USER) ; `
#     $sid = $userAccount.Translate([System.Security.Principal.SecurityIdentifier]).Value ; `
#     $profileListPath = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\{0}' -f $sid ; `
#     New-Item -Path $profileListPath -Force | Out-Null ; `
#     New-ItemProperty -Path $profileListPath -Name 'ProfileImagePath' -Value $profilePath -PropertyType String -Force | Out-Null

# USER $IMAGE_USER

# RUN git config --system core.longpaths true ; `
#     Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem' -Name LongPathsEnabled -type DWord -Value 1

# VOLUME "${AGENT_ROOT}"/.jenkins
# VOLUME "${AGENT_WORKDIR}"
# WORKDIR "${AGENT_ROOT}"
# LABEL `
#     org.opencontainers.image.vendor="Jenkins project" `
#     org.opencontainers.image.title="Official Jenkins Agent Base Docker image" `
#     org.opencontainers.image.description="This is a base image, which provides the Jenkins agent executable (agent.jar)" `
#     org.opencontainers.image.version="${VERSION}" `
#     org.opencontainers.image.url="https://www.jenkins.io/" `
#     org.opencontainers.image.source="https://github.com/jenkinsci/docker-agent" `
#     org.opencontainers.image.licenses="MIT"

# ## Inbound Agent image target
# FROM agent AS inbound-agent

# COPY jenkins-agent.ps1 C:/ProgramData/Jenkins

# LABEL `
#     org.opencontainers.image.vendor="Jenkins project" `
#     org.opencontainers.image.title="Official Jenkins Inbound Agent Base Docker image" `
#     org.opencontainers.image.description="This is an image for Jenkins agents using TCP or WebSockets to establish inbound connection to the Jenkins controller" `
#     org.opencontainers.image.version="${VERSION}" `
#     org.opencontainers.image.url="https://www.jenkins.io/" `
#     org.opencontainers.image.source="https://github.com/jenkinsci/docker-agent" `
#     org.opencontainers.image.licenses="MIT"

# ENTRYPOINT ["pwsh.exe", "-f", "C:/ProgramData/Jenkins/jenkins-agent.ps1"]
# #### END BEFORE
