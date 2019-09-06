#!/usr/bin/env bash

#---------------------------------------------
# Variables
#---------------------------------------------
JDK_HOME="${1:-.}"
JDK_HOME="$(realpath ${JDK_HOME})"
JDK_HOME="${JDK_HOME%/}"
OS_JVM_DIRECTORY="/usr/lib/jvm"
JDK_LINK=${OS_JVM_DIRECTORY}/$(echo $(basename ${JDK_HOME}) | sed -re 's@java-@java-1.@;s@jdk-@jdk-1.@;s@jre-@jre-1.@')
JDK_NAME=$(basename ${JDK_HOME})
JDK_ALIAS=$(basename ${JDK_LINK})
JINFO_FILE=${OS_JVM_DIRECTORY}/.${JDK_ALIAS}.jinfo
JDK_ALTERNATIVE_PRIORITY=$(( (RANDOM % 9000 ) + 1000 ))

#---------------------------------------------
# Functions
#---------------------------------------------

error() {
  echo -en "\nError: $@\n" 1>&2
  exit 1
}

info() {
  echo -en "\n-> $@"
}

pause() {
  echo -en "\n"
  read -p "$@"
}

check_syntax() {
  if [ ${#BASH_ARGV[@]} -ne 1 ]; then
    error "Wrong parameter count\nSyntax: $(basename -s .sh $0) <jdk_directory>"
  fi
}

check_rights() {
  if [ "$EUID" -ne 0 ]; then
    error "You need root privileges for running this script."
  fi
}

check_jdk() {
  if [[ ! -d ${JDK_HOME} ]] || ( [[ ! -x ${JDK_HOME}/jre/bin/java ]] && [[ ! -x ${JDK_HOME}/bin/java ]] ) ; then
    error "'${JDK_HOME}' must point to a valid Java JDK home."
  fi
}

setup_fs_links() {
  rm ${JDK_LINK}
  ln -s ${JDK_HOME} ${JDK_LINK}
  rm ${OS_JVM_DIRECTORY}/default-java
  ln -s ${JDK_LINK} ${OS_JVM_DIRECTORY}/default-java
}

generate_jinfo_header() {
  echo "name=${JDK_NAME}" > ${JINFO_FILE}
  echo "alias=${JDK_ALIAS}" >> ${JINFO_FILE}
  echo "priority=${JDK_ALTERNATIVE_PRIORITY}" >> ${JINFO_FILE}
  echo "section=main" >> ${JINFO_FILE}
}

setup_jdk_alternative() {
  update-alternatives --install /usr/bin/$1 $1 ${JDK_LINK}/bin/$1 ${JDK_ALTERNATIVE_PRIORITY}
  update-alternatives --set $1 ${JDK_LINK}/bin/$1
  echo "jdk $1 ${JDK_LINK}/bin/$1" >> $JINFO_FILE
}

setup_alternatives() {
  for it in $(ls ${JDK_LINK}/bin); do
    if [[ -x ${JDK_LINK}/bin/${it} ]]; then
      setup_jdk_alternative ${it}
    fi
  done
}

set_config_variable(){
    FILE=$1
    VARIABLE=$2
    VALUE=$3
    grep -q '^'"${VARIABLE}"'=' "${FILE}" && \
    sed -i -re 's@^('"${VARIABLE}"'=).*@\1'"${VALUE}"'@' "${FILE}" || \
    echo "${VARIABLE}=${VALUE}" | tee -a "${FILE}" > /dev/null
}

set_config_variable_before(){
    FILE=$1
    VARIABLE=$2
    VALUE=$3
    PATTERN=$4
    grep -q '^'"${VARIABLE}"'=' "${FILE}" && \
    sed -i -re 's@^('"${VARIABLE}"'=).*@\1'"${VALUE}"'@' "${FILE}" || \
    sed -i -re '/^'"${PATTERN}"'=.*/i '"${VARIABLE}=${VALUE}" "${FILE}"
}

set_environment_java_variable() {
  grep -q '^PATH=' /etc/environment && \
  set_config_variable_before /etc/environment JAVA_HOME "${JDK_LINK}" "PATH" || \
  set_config_variable /etc/environment JAVA_HOME "${JDK_LINK}" 
}

#---------------------------------------------
# Main
#---------------------------------------------

check_syntax 

echo "You are going to setup the OS environment to use Java from '${JDK_HOME}'"

info 'Checking execution rights'
check_rights

info 'Checking JDK existence at the right place'
check_jdk

pause 'Press [Enter] key to continue...'

info "Creating symbolic links"
setup_fs_links

info "Generating a .jinfo file for the update-java-alternatives command"
generate_jinfo_header

info "Registering the executables with the alternatives system"
setup_alternatives

info "Updating JAVA_HOME environment variable"
set_environment_java_variable

info "Done\n"

