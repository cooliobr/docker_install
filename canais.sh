#!/bin/bash

# Endpoint do servidor
url="http://172.22.0.2/servidor3_udp.php?parametro=iniciar"

# Arquivo de saída
output_file="/opt/conf/canais.lua"

# Requisição ao servidor e armazenamento da resposta
response=$(curl -s "$url")

# Limpa o arquivo de saída
echo -n > "$output_file"

# Loop sobre as linhas da resposta
while IFS= read -r line; do
            # Tenta extrair os campos usando ":" como delimitador
                IFS=':' read -r -a fields <<< "$line"

    # Verifica se há pelo menos 5 campos
    if [[ ${#fields[@]} -ge 5 ]]; then
        # Cria uma linha no arquivo de saída
        echo "make_channel({name = \"${fields[0]}\", input = {\"udp://@${fields[1]}:${fields[2]}\"}, output = {\"http://0.0.0.0:8000/udp/${fields[1]}:${fields[2]}\",}})" >> "$output_file"
    else
        echo "Linha ignorada (não possui campos suficientes): $line"
    fi

done <<< "$response"

echo "Arquivo $output_file gerado com sucesso!"

# Arquivo de serviço
service_file="/etc/systemd/system/astra.service"

# Linha a ser substituída
old_line="ExecStart=/usr/local/src/astra-4/astra --relay"
new_line="ExecStart=/usr/local/src/astra-4/astra /opt/conf/canais.lua --log /var/log/astra.log"

# Substituir a linha usando sed
sed -i "s|$old_line|$new_line|g" "$service_file"

echo "Substituição concluída."
systemctl daemon-reload
systemctl restart astra
