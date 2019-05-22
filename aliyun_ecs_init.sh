#!/bin/bash
set -e

yum install -y mosh

# disk
TGTDEV=/dev/vdb
# to create the partitions programatically (rather than manually)
# we're going to simulate the manual input to fdisk
# The sed script strips off all the comments so that we can
# document what we're doing in-line with the actual commands
# Note that a blank line (commented as "defualt" will send a empty
# line terminated with a newline to take the fdisk default.
# reference: https://superuser.com/questions/332252/how-to-create-and-format-a-partition-using-a-bash-script
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | sudo fdisk ${TGTDEV}
  o # clear the in memory partition table
  n # new partition
  p # primary partition
  1 # partion number 1
    # default, start immediately after preceding partition
    # default, extend partition to end of disk
  p # print the in-memory partition table
  w # write the partition table
  q # and we're done
EOF

sudo mkfs.ext4 /dev/vdb1
# TODO: make sure we can access mechine even the disk failed
mkdir -p /home
echo /dev/vdb1 /home ext4 defaults 0 0 >> /etc/fstab
mount -a

# users
NEWUSER=teng
useradd -G wheel ${NEWUSER}
# cp -r /root/.ssh /home/teng
mkdir "/home/${NEWUSER}/.ssh"
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDAPKSyP5a2QjhXIsf8MszKNNb5E8bgbxuv4KHAyqImYnYbDPZOHm3eoOcSPsBMSNI1viADk3+aLmoGmOyGU8xr2dktfOWq2+kkr/s9aKS9yuFi8LqSqU5XuftC3lOdE+uPRfEQLRhLXbMt9HJ/rhaMwY0okwxVSEtlDSXQIkyVvxjBxANv2P1idmiAHfZVqH5Ob+jN0vRmGR6kfYLXKCS5BkEyIVohAo3FNjBOIrv/DC+acad13ivIANMyRntdX9LYbvuLP9kNURqt41PKZbzMKNi549ve/+/G2lWvFlLreURBAEgO8GrDuCVK2c8xvPS9eOfJBJmchRfS04cPAds7 teng@teng-macbook" > "/home/${NEWUSER}/.ssh/authorized_keys"
chmod -R go-rw "/home/${NEWUSER}/.ssh"
chown -R ${NEWUSER}:${NEWUSER} "/home/${NEWUSER}/.ssh"
echo "******" | passwd ${NEWUSER} --stdin

# sudo
sed -i -e 's/^\(%wheel\)/# \1/g' /etc/sudoers
sed -i -e 's/^#\s*\(%wheel\s.*NOPASSWD\)/\1/g' /etc/sudoers

# sshd
sed -i -e 's/^#\(KerberosAuthentication\)/\1/g' /etc/ssh/sshd_config
sed -i -e 's/^\(PasswordAuthentication\|PermitRootLogin\|UsePAM\|GSSAPIAuthentication\|KerberosAuthentication\) yes/\1 no/g' /etc/ssh/sshd_config
sed -i -e "s/\(Subsystem\s.*\)$/\1\n\nAllowUsers ${NEWUSER}/g" /etc/ssh/sshd_config
systemctl restart sshd

# su teng
su teng
cd ~
sudo yum install -y git zsh tmux jq
sudo usermod -s /bin/zsh teng
touch ~/.zshrc
exit

# su teng (zsh)
su teng
cd ~

# oh-my-zsh (plugins)
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
sed -i -e 's/^\(plugins=(.*\)$/\1\n  zsh-autosuggestions\n  zsh-syntax-highlighting/g' ~/.zshrc
# oh-my-zsh (theme)
cp ~/.oh-my-zsh/themes/robbyrussell.zsh-theme ~/.oh-my-zsh/custom/themes/mytheme.zsh-theme
sed -i -e 's/^\(PROMPT='"'"'\)\(\${ret_status}\)/\1%{$fg_bold[white]%}%M \2/g' ~/.oh-my-zsh/custom/themes/mytheme.zsh-theme
#sed -i -e 's/^\(ZSH_THEME=\).*$/\1"mytheme"/g' ~/.zshrc
sed -i -e 's/^\(ZSH_THEME=\).*$/\1"af-magic"/g' ~/.zshrc
# oh-my-zsh (reload)
source ~/.zshrc

# tmux
curl https://raw.githubusercontent.com/tengattack/dotfiles/master/tmux.conf -o ~/.tmux.conf
sed -i -e 's/^\(set -g mouse \)/#\1/g' ~/.tmux.conf
sed -i -e 's/^\(set -g status-right \)/#\1/g' ~/.tmux.conf
sed -i -e 's/^\(#\s*old version[\S\s]*\)#\s*\(set -g status-right \)/\1\n\2/g' ~/.tmux.conf
# replace for old version tmux
# reference: https://stackoverflow.com/questions/1251999/how-can-i-replace-a-newline-n-using-sed
sed -i -e ':a;N;$!ba;s/^\(#\s*for old version .*\)\n#\s*/\1\n/mg' ~/.tmux.conf
sudo mv ~/.tmux.conf /etc/tmux.conf

# docker (CentOS)
# reference: https://docs.docker.com/install/linux/docker-ce/centos/
sudo yum install -y yum-utils \
  device-mapper-persistent-data \
  lvm2 nfs-utils
sudo yum-config-manager \
  --add-repo \
  https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install -y docker-ce
sudo systemctl enable docker
sudo systemctl start docker
sudo docker run hello-world
echo '{\n  "insecure-registries": ["docker00:5000"]\n}' | sudo tee /etc/docker/daemon.json
sudo systemctl restart docker
# TODO: join swarm
# ...
# docker (users)
sudo usermod -aG docker teng

# reload user group
exit
su teng
cd ~

# beats
sudo tee /etc/yum.repos.d/elasticsearch.repo << EOF
[elasticsearch-6.x]
name=Elasticsearch repository for 6.x packages
baseurl=https://artifacts.elastic.co/packages/6.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
EOF
sudo yum install -y metricbeat-6.2.4-1.x86_64
echo 'alias metricbeat="/usr/share/metricbeat/bin/metricbeat -c /etc/metricbeat/metricbeat.yml -path.home /usr/share/metricbeat -path.config /etc/metricbeat -path.data /var/lib/metricbeat -path.logs /var/log/metricbeat"' | sudo tee -a /etc/profile
