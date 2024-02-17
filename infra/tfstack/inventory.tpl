[servers]
%{ for name, ip in servers ~}
${i@} hostname=${name}
%{ endfor ~}
