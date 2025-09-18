[servers]
%{ for name, ip in servers  ~}
${ip} hostname=${name}
%{ endfor ~}

[servers:vars]
ansible_user=ubuntu
%{ for network in networks ~}
${network.name}=${network.addresses[0]}
%{ endfor ~}
