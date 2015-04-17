param([Parameter(Mandatory=$true,ValueFromPipeline=$true)] 
      [string]
      $installation_path, 
      [Parameter(Mandatory=$true,ValueFromPipeline=$true)] 
      [string]
      $marathon_host, 
      [int]
      $marathon_port=8080
      )
      $UNIVERSE_URI="https://github.com/mesosphere/universe/archive/ea.zip"

if (-Not(Get-Command virtualenv -errorAction SilentlyContinue))
{
     echo "Cannot find virtualenv. Aborting."
     exit 1
}
$VIRTUAL_ENV_VERSION = (virtualenv --version)

$VIRTUAL_ENV_VERSION  -match "[0-9]+"

if ($matches[0] -lt 12) {
echo "Virtualenv version must be 12 or greater. Aborting."
	exit 1
}
echo "Installing DCOS CLI from wheel..."
echo ""

if (-Not([System.IO.Path]::IsPathRooted("$installation_path"))) {
$installation_path = Join-Path (pwd) $installation_path
}

if (-Not( Test-Path $installation_path)) {
mkdir  $installation_path
}

& virtualenv $installation_path
& $installation_path\Scripts\activate
& easy_install  "http://downloads.sourceforge.net/project/pywin32/pywin32/Build%20219/pywin32-219.win32-py2.7.exe?r=&ts=1429187018&use_mirror=heanet" 2>&1 | out-null

$DCOS_WHEEL_FILE="dcos-0.1.0-py2.py3-none-any.whl"
$DCOSCLI_WHEEL_FILE="dcoscli-0.1.0-py2.py3-none-any.whl"
$DCOS_WHEEL_FILE_FULL_PATH = "$installation_path\$DCOS_WHEEL_FILE"
$DCOSCLI_WHEEL_FILE_FULL_PATH = "$installation_path\$DCOSCLI_WHEEL_FILE"

$client = new-object System.Net.WebClient
$client.DownloadFile("https://downloads.mesosphere.io/dcos-cli/${DCOS_WHEEL_FILE}", $DCOS_WHEEL_FILE_FULL_PATH)

& $installation_path\Scripts\pip install --quiet ${DCOS_WHEEL_FILE_FULL_PATH}
rm ${DCOS_WHEEL_FILE_FULL_PATH}

$client.DownloadFile("https://downloads.mesosphere.io/dcos-cli/${DCOSCLI_WHEEL_FILE}", $DCOSCLI_WHEEL_FILE_FULL_PATH)
& $installation_path\Scripts\pip install --quiet ${DCOSCLI_WHEEL_FILE_FULL_PATH}
rm ${DCOSCLI_WHEEL_FILE_FULL_PATH}



[Environment]::SetEnvironmentVariable("Path", "$installation_path\Scripts\;", "User")
$env:Path="$env:Path;$installation_path\Scripts\"

$DCOS_CONFIG="$env:USERPROFILE\.dcos\dcos.toml"

if (-Not(Test-Path $DCOS_CONFIG)) {
mkdir "$env:USERPROFILE\.dcos"
New-Item $DCOS_CONFIG -type file
}
[Environment]::SetEnvironmentVariable("DCOS_CONFIG", "$DCOS_CONFIG", "User")
$env:DCOS_CONFIG = $DCOS_CONFIG

dcos config set marathon.host $marathon_host
dcos config set marathon.port $marathon_port