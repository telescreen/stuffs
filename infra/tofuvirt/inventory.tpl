[servers]
%{ for name, ip in servers  ~}
${ip} hostname=${name}
%{ endfor ~}

