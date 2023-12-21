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
systemctl daemon-reload
systemctl restart astra
