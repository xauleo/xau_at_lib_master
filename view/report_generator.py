import streamlit as st
import time
from datetime import datetime

import streamlit as st
from datetime import datetime

def display_current_time():
    """Função para exibir a data e o horário em tempo real"""
    current_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    st.sidebar.markdown(f"**Data e Hora Atual:** {current_time}")

def display_analysis(analysis_text):
    st.subheader("Análise da IA")
    st.write(analysis_text)

