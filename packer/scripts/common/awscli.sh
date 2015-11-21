#!/bin/bash

set -e

export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

export DEBIAN_FRONTEND=noninteractive DEBIAN_PRIORITY=critical
export DEBCONF_NONINTERACTIVE_SEEN=true

readonly UBUNTU_RELEASE=$(lsb_release -sc)

if [[ -z $AWS_DEFAULT_REGION ]]; then
    # Set default desirable region.
    AWS_DEFAULT_REGION='eu-west-1'
fi

if [[ -n $AWSCLI_VERSION ]]; then
    pip install awscli==${AWSCLI_VERSION}
else
    pip install awscli
fi

rm -f \
    /usr/local/bin/aws.cmd \
    /usr/local/bin/aws_zsh_completer.sh

for f in /usr/local/bin/aws*; do
    ln -sf $f /usr/bin/${f##*/}
done

hash -r

cat <<'EOF' | tee /etc/bash_completion.d/aws
complete -C aws_completer aws
EOF

chown root:root /etc/bash_completion.d/aws
chmod 644 /etc/bash_completion.d/aws

for u in $(echo "root vagrant ubuntu ${USER}" | tr ' ' '\n' | sort -u); do
    if getent passwd $u &>/dev/null; then
        # Not using the "HOME" environment variable here,
        # to avoid breaking things during the image build.
        eval HOME_DIRECTORY='~'${u}

        [[ -d ${HOME_DIRECTORY}/.aws ]] || mkdir -p ${HOME_DIRECTORY}/.aws

        # Basic, just to set correct region.
        cat <<EOF | sed -e '/^$/d' | tee ${HOME_DIRECTORY}/.aws/config
[default]
$(if [[ $PACKER_BUILDER_TYPE =~ ^amazon-.+$ ]]; then
    printf "%s = %s" "region" $AWS_DEFAULT_REGION
  fi)
output = json
EOF

        # Make sure permissions are set for the desired user.
        chown -R ${u}:$(id -gn $u 2>/dev/null) ${HOME_DIRECTORY}/.aws
        chmod 700 ${HOME_DIRECTORY}/.aws
        chmod 600 ${HOME_DIRECTORY}/.aws/config
    fi
done
