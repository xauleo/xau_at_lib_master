# llm_analisys.py

import openai

def initialize_openai(api_key):
    openai.api_key = api_key

def generate_analysis(data, macro_data, sentiment_data, news_articles):
    try:
        # Prepara os dados mais recentes
        latest_data = data.iloc[-1]

        # Verifica se macro_data é um dicionário
        latest_macro = macro_data if isinstance(macro_data, dict) else {}

        # Verifica se sentiment_data é um dicionário
        latest_sentiment = sentiment_data if isinstance(sentiment_data, dict) else {}

        # Processa as notícias para incluir no prompt
        news_text = ""
        max_articles = 5  # Limita o número de artigos para evitar um prompt muito longo
        for i, artigo in enumerate(news_articles[:max_articles]):
            titulo = artigo.get('title', 'Título não disponível')
            descricao = artigo.get('description', '')
            conteudo = artigo.get('content', '')
            news_text += f"Notícia {i+1} - Título: {titulo}\nDescrição: {descricao}\nConteúdo: {conteudo}\n\n"

        # Constrói o prompt
        prompt = f"""
        Analise os seguintes indicadores para o XAU/USD:

        **Indicadores Técnicos:**
        - Preço de Fechamento Atual: {latest_data.get('close', 'N/A')}
        - SMA 50: {latest_data.get('SMA_50', 'N/A')}
        - SMA 200: {latest_data.get('SMA_200', 'N/A')}
        - RSI 14: {latest_data.get('RSI_14', 'N/A')}
        - Bandas de Bollinger: Superior {latest_data.get('BBU', 'N/A')}, Média {latest_data.get('BBM', 'N/A')}, Inferior {latest_data.get('BBL', 'N/A')}
        - Momentum: {latest_data.get('Momentum', 'N/A')}
        - MACD: {latest_data.get('MACD', 'N/A')}
        - Linha de Sinal do MACD: {latest_data.get('MACD_signal', 'N/A')}
        - Ichimoku Cloud:
            - Tenkan-sen: {latest_data.get('ICH_TS_9', 'N/A')}
            - Kijun-sen: {latest_data.get('ICH_KS_26', 'N/A')}
            - Senkou Span A: {latest_data.get('ICH_SSA_26', 'N/A')}
            - Senkou Span B: {latest_data.get('ICH_SSB_52', 'N/A')}
        - Parabolic SAR: {latest_data.get('PSARl_0.02_0.2_PSAR_', 'N/A')} (Longo), {latest_data.get('PSARs_0.02_0.2_PSAR_', 'N/A')} (Curto)
        - Níveis de Fibonacci (baseados nos últimos 14 períodos):
            - Nível 0% (Alta): {latest_data.get('Fibo_0', 'N/A')}
            - Nível 23.6%: {latest_data.get('Fibo_23.6', 'N/A')}
            - Nível 38.2%: {latest_data.get('Fibo_38.2', 'N/A')}
            - Nível 50%: {latest_data.get('Fibo_50.0', 'N/A')}
            - Nível 61.8%: {latest_data.get('Fibo_61.8', 'N/A')}
            - Nível 78.6%: {latest_data.get('Fibo_78.6', 'N/A')}
            - Nível 100% (Baixa): {latest_data.get('Fibo_100', 'N/A')}

        **Indicadores Macroeconômicos:**
        - Taxas de Juros Reais: {latest_macro.get('real_interest_rates', 'N/A')}
        - Índice do Dólar Americano (DXY): {latest_macro.get('dxy', 'N/A')}
        - Inflação (CPI - variação anual): {latest_macro.get('cpi_pct_change', 'N/A')}%
        - Inflação ao Produtor (PPI - variação anual): {latest_macro.get('ppi_pct_change', 'N/A')}%
        - PIB Real dos EUA: {latest_macro.get('gdp', 'N/A')}
        - Taxa de Desemprego: {latest_macro.get('unemployment_rate', 'N/A')}%
        - Folha de Pagamento Não-Agrícola (Non-Farm Payroll): {latest_macro.get('nonfarm_payroll', 'N/A')}
        - Pedidos Iniciais de Seguro-Desemprego: {latest_macro.get('initial_jobless_claims', 'N/A')}
        - JOLTS Abertura de Vagas: {latest_macro.get('jolts_job_openings', 'N/A')}
        - Comunicados do FOMC: {latest_macro.get('fomc', 'N/A')}

        **Indicadores de Sentimento:**
        - Índice VIX: {latest_sentiment.get('vix', 'N/A')}
        - Posições Líquidas do Relatório COT: {latest_sentiment.get('cot_net_positions', 'N/A')}
        - Índice de Medo e Ganância: {latest_sentiment.get('fear_greed_index', 'N/A')}
        - Sentimento de Mídias Sociais: {latest_sentiment.get('social_sentiment', 'N/A')}

        **Indicadores Quantitativos:**
        - ATR: {latest_data.get('ATR', 'N/A')}
        - Z-Score de Reversão à Média: {latest_data.get('z_score', 'N/A')}
        - Previsão de Volatilidade GARCH: {latest_data.get('GARCH_Volatility', 'N/A')}

        **Notícias Recentes Relacionadas ao XAU/USD:**
        {news_text}

        Com base nesses indicadores e nas notícias recentes, forneça uma análise detalhada da tendência atual do mercado para o XAU/USD, identifique possíveis níveis de suporte e resistência, e discuta quaisquer sinais potenciais de negociação. Inclua como os fatores macroeconômicos e as notícias recentes podem estar influenciando o mercado de ouro neste momento.
        """

        # Gera a análise usando a API OpenAI
        response = openai.ChatCompletion.create(
            model='gpt-4',
            messages=[{'role': 'user', 'content': prompt}],
            max_tokens=1500,
            temperature=0.5
        )
        analysis = response['choices'][0]['message']['content']
        return analysis

    except Exception as e:
        error_message = f"Erro ao gerar análise com o OpenAI: {e}"
        print(error_message)
        return error_message
