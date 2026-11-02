@echo off
cd /d "%~dp0"
echo Para abrir em outro dispositivo na mesma rede Wi-Fi, use o IP deste computador
echo (consulte com ipconfig) seguido de :8000, por exemplo http://192.168.1.10:8000/
echo O acesso por IP local pode nao permitir instalacao PWA/offline no celular sem HTTPS.
start "Servidor local - RPG Fichas" cmd /k "cd /d ""%~dp0.."" && python -m uvicorn src.main:app --host 0.0.0.0 --port 8000"
timeout /t 3 /nobreak >nul
start "" http://localhost:8000/
