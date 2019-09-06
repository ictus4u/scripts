#!/usr/bin/env bash

if [[ -z "$1" ]]; then
    echo "Usage: $(basename $0) <new_image_name> [<Dockerfile>]"
    exit 1
fi

my_working_dir="$(pwd)/"

if [[ "$2"=="" ]]; then
    dockerfile_path="${my_working_dir}Dockerfile"
else
    dockerfile_path=$2
fi
dockerfile=$(basename ${dockerfile_path})
docker_image_name=$1
image_name=$(echo ${docker_image_name} | cut -d":" -f1)
username=$(id -un)


remote_server="tt@fjfj.pl"
remote_dir="/home/tt/downloads/${username}/docker-build/"

local_server="zero@zero.aleph"
local_server_dir="/var/lib/public/docker-built/${username}/"

printf "INFO: %s\n" "Stage 1: Creating remote working dirs."
RESULT=$(ssh -T ${remote_server}  << EOSSH
if [ ! -d "${remote_dir}" ]; then
	mkdir -p "${remote_dir}";
fi
EOSSH
)
echo ${RESULT}
RESULT=$(ssh -T ${local_server}  << EOSSH
if [ ! -d "${local_server_dir}" ]; then
	mkdir -p "${local_server_dir}";
fi
EOSSH
)
echo ${RESULT}

printf "INFO: %s\n" "Stage 2: Uploading Dockerfile."
scp "${dockerfile_path}" "${remote_server}:${remote_dir}"

printf "INFO: %s\n" "Stage 3: Building docker image"
## Create docker image and save it
RESULT=$(ssh -T ${remote_server}  << EOSSH
cd "${remote_dir}"
docker build -t "${docker_image_name}" -f "${dockerfile}" .
docker save "${docker_image_name}" | gzip > "${image_name}.tar.gz"
docker rmi "${docker_image_name}"
7z a -mx=9 "${image_name}.7z" "${image_name}.tar.gz"
rm "${image_name}.tar.gz"
EOSSH
)
echo ${RESULT}

printf "INFO: %s\n" "Stage 4: Downloading image inside a screen on Zero server."
RESULT=$(ssh -T ${local_server} <<-EOSSH
	cat <<-'EOT' > "${local_server_dir}${image_name}.sh"
		#!/usr/bin/env bash
		# TODO: execute it into screen
		if [ -z "\$STY" ]; then
			exec screen -dm -S "${image_name}" /bin/bash "\$0";
		else
			# Download it... no hurry
			while ! rsync -P "${remote_server}:${remote_dir}${image_name}.7z" "${local_server_dir}"; do
				sleep 60;
			done
			7z e ${image_name}.7z
			# Cleanup
			rm ${image_name}.7z
			ssh ${remote_server} rm "${remote_dir}${image_name}.7z" "${remote_dir}${dockerfile}"
		    rm "\$0"
		fi
	EOT
	chmod +x "${local_server_dir}${image_name}.sh"
	/bin/bash "${local_server_dir}${image_name}.sh"
EOSSH
)
echo ${RESULT}

printf "INFO: %s\n" "Stage 5: Disconnected from screen."
echo "Watch at $(echo ${local_server} |cut -d"@" -f2)) for 'screen -x ${image_name}' while download completes."
read -p "Do you want to connect to that screen? [y/N]:" OPT
case ${OPT} in
    y|Y)
        echo "Be careful! Remember to disconnect with Ctrl+A+D from screen ;-)"
        read -P "Press ENTER to continue..."
        ssh -t "${local_server}" screen -x "${image_name}"

        ;;
    *)
        ;;
esac
echo ""
echo "READ IT:"
echo ""
echo "You can monitor screen with (Remember to disconnect with Ctrl+A+D):"
echo "ssh -t '${local_server}' screen -x '${image_name}'"
echo ""
echo "The resulting download will be on '${local_server_dir}'"
echo ""
echo "You may copy it by using the following command after download end:"
echo "scp '${local_server}:${local_server_dir}${image_name}.tar.gz' '${my_working_dir}'"
