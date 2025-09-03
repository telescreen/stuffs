[servers]
%{ for name, ip in servers  ~}
${ip} hostname=${name}
%{ endfor ~}

[servers:vars]
ansible_user=ubuntu
