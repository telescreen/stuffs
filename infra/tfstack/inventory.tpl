[servers]
%{ for name, spec in servers ~}
${spec.network[0].fixed_ip_v4} hostname=${name}
%{ endfor ~}
