Tâches
6. The Service Guesser
Niveau: 0 Correction automatique

Goal: Identify services even without a banner.

Context: Some services are silent. They don't send a banner until you send the right data. Example: A DNS server won't say "Hello". You must send a query. If get_banner returns empty, we can guess based on the port (Unreliable but better than nothing).

Instructions: Implement guess_service(port: int) -> str.

    Create a dictionary of common ports (21=FTP, 22=SSH, 80=HTTP, 443=HTTPS, 3306=MySQL).

    If the banner is empty, return the "Guessed" service name based on the port number.

Expected Output:

# Assuming Port 80 is open but sends no banner
print(get_service_info("192.168.1.1", 80))
# Output: "HTTP (Guessed)"

Dépôt:

    Dépôt GitHub: holbertonschool-cybersecurity
    Répertoire: python_for_cyber/4x02_network_probing
    Fichier: net_probe.py
    Langage de code: (basé sur le projet)

