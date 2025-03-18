#!/bin/sh
info(){
	echo "[$(date +'%F %H:%m:%S')] INFO  - $1"
}
error(){
	RED='\033[0;31m'
	NC='\033[0m' # No Color
	echo -e "${RED}[$(date +'%F %H:%m:%S')] ERROR - $1${NC}" > /dev/stderr
}
warn(){
	YELLOW='\033[0;33m'
	NC='\033[0m' # No Color
	echo -e "${YELLOW}[$(date +'%F %H:%m:%S')] WARN  - $1${NC}" > /dev/stderr
}


info "Starting Doxygen Docker"
echo
info "Checking parameters"

#GIT_REPO
if [ -z "$GIT_REPO" ]; then
	error "No git repo was specified. Please set the GIT_REPO usign the parameter -e GIT_REPO='git@github.com:mart123p/docker-doxygen.git'"
	exit 1
fi
echo "$GIT_REPO" > /var/data/config/git_repo

#API_KEY
if [ -z "$API_KEY" ]; then
	warn "No api key was specified for the git hook. Will generate one."
	API_KEY=$( < /dev/urandom tr -dc a-z0-9 | head -c${1:-32};echo)
	info "API_KEY: $API_KEY"
	echo
fi
echo $API_KEY > /var/data/config/apikey

info "Parameters checking done."
echo
usermod -aG tty nginx
chown -R nginx:nginx /var/data/config/
echo
su -s /bin/sh -c "/usr/sbin/atd"
info "Starting FastCGI"
chown -R nginx:nginx /var/run/fcgiwrap/
su nginx -s /bin/sh -c "/usr/bin/fcgiwrap -s unix:/var/run/fcgiwrap/fcgiwrap.sock"&
info "FastCGI started"

mkdir -p /run/nginx/
touch /run/nginx/nginx.pid 
info "Nginx started"
echo
echo "--Nginx Logs--"
/usr/sbin/nginx -c /etc/nginx/nginx.conf -g "daemon off;"
