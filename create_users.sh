#!/bin/bash

# RootID
root_id=0
# GruppID
group_id=1000
# Mappar som ska kontrolleras och skapas
default_folders=(
    "Documents"
    "Downloads"
    "Work"
)

# Behörighetskontroll
if [ $EUID -ne ${root_id} ]; then
    # Om inte root, skriv ut felmeddelande och avsluta med felkod
    echo "Du behöver exekvera detta skript som root-användare (0)"
    exit 1
fi

# Användarskapande
# Går genom mottagna argument
for user in $@; do
    # Skapar användare `user` med ett hem inom user gruppen (1000)
    echo "Skapar användare ${user}"
    useradd -m -g ${group_id} ${user}
    # Går genom varje mapp som ska kontrolleras och skapas
    for folder in ${default_folders[@]}; do
        # Kontrollera om den existerar
        if [ ! -d "/home/${user}/${folder}" ]; then
            # Om ej, skapa den inom användarens hem
            echo "${folder} does not exist, creating .."
            mkdir "/home/${user}/${folder}"
        fi
    done
    # Skapa filen `welcome.txt` inom användarens hem
    echo "Välkommen ${user}" > /home/${user}/welcome.txt
done

# Processen delas upp i två loops: först skapas alla användare och sedan så genereras användarlistorna.
# Detta eftersom tidigare så genererades användarlistorna i samma loop där användaren skapades och då missar `gencomp -u` användarna som kommer därefter.
for user in $@; do
    for a_user in $(compgen -u); do
        echo ${a_user} >> /home/${user}/welcome.txt
    done
    # Korrigera rättigheter genom hela hemmappen
    chown -R ${user}:${group_id} /home/${user}
    chmod -R a-rwx,u+rwx /home/${user}
done