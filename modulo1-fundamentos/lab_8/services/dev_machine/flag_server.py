# services/dev_machine/flag_server.py
# (sem alterações)
import socket

HOST = '0.0.0.0'
PORT = 1337
FLAG = "KENSEI{D3SC0BR1ND0_P0RT4S_3SC0ND1D4S}\n"

with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    s.bind((HOST, PORT))
    s.listen()
    print(f"Servidor da Flag escutando na porta {PORT}...")
    while True:
        conn, addr = s.accept()
        with conn:
            print(f"Conexão da flag recebida de {addr}")
            conn.sendall(FLAG.encode('utf-8'))