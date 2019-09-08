#!/usr/bin/env bash

if [[ "$1" == "--help" ]]; then
    echo "Usage: $(basename $0) [<tex file>]"
    exit 1
fi

my_working_dir="$(pwd)/"

if [ "$1" == "" ]; then
    texfile_path="main.tex"
else
    texfile_path=$1
fi

texfile=$(basename ${texfile_path})
pdffile=$(basename -s .tex ${texfile_path}).pdf

username=$(id -un)

remote_server="tt@fjfj.pl"
remote_dir="/home/tt/lab/latex/${username}/"

printf "INFO: %s\n" "Stage 1: Creating remote working dirs."
RESULT=$(ssh -A -T ${remote_server}  << EOSSH
if [ ! -d "${remote_dir}" ]; then
	mkdir -p "${remote_dir}";
fi
EOSSH
)
echo ${RESULT}

printf "INFO: %s\n" "Stage 2: Uploading tex project."
# scp -r ${my_working_dir}* "${remote_server}:${remote_dir}"
rsync -rzvh --exclude '*.pdf' --delete ${my_working_dir}* "${remote_server}:${remote_dir}"


printf "INFO: %s\n" "Stage 3: Build text"
RESULT=$(ssh -A -T ${remote_server} <<-EOSSH
	cat <<-'EOT' > "${remote_dir}latexdockercmd.sh"
        #!/usr/bin/env sh
        IMAGE=blang/latex:ctanfull # Modified into ctanfull
        exec docker run --rm -i --user="\$(id -u):\$(id -g)" --net=none -v "\$PWD":/data "\$IMAGE" "\$@"
	EOT
	chmod +x "${remote_dir}latexdockercmd.sh"
	cd ${remote_dir} && ./latexdockercmd.sh /bin/sh -c "pdflatex ${texfile} && pdflatex ${texfile}"
EOSSH
)
echo ${RESULT}

printf "INFO: %s\n" "Stage 4: download built pdf."
scp "${remote_server}:${remote_dir}${pdffile}" "${my_working_dir}"