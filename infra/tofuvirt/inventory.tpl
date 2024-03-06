[servers]
%{ for name, ip in servers  ~}
${ip} ansible_host=${name}
%{ endfor ~}

[servers:vars]
ansible_user=ubuntu
