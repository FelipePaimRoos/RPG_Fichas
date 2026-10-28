from pypdf import PdfReader
import re

def extrair_secoes_pdf(caminho_pdf):
    print("A ler o PDF...")
    reader = PdfReader(caminho_pdf)
    total_paginas = len(reader.pages)
    print(f"Total de páginas encontradas: {total_paginas}")

    texto_completo = ""
    for i, pagina in enumerate(reader.pages):
        t = pagina.extract_text()   
        if t:
            texto_completo += f"\n--- PÁGINA {i+1} ---\n" + t

    # Exemplo de busca por seções (ajuste as palavras-chave conforme o índice do seu livro)
    secoes = {
        "itens": ["EQUIPAMENTOS", "ITENS", "ARMAS"],
        "rituais": ["RITUAIS", "MAGIAS"],
        "poderes": ["PODERES", "HABILIDADES"]
    }

    print("Extração concluída com sucesso! O texto bruto está pronto para ser mapeado.")
    return texto_completo

# Substitua pelo caminho real do seu PDF
# extrair_secoes_pdf("caminho/para/seu_livro.pdf")