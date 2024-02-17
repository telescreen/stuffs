[servers]
%{ for ip in servers  ~}
${ip}
%{ endfor ~}

