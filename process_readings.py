import pandas as pd
import numpy as np
import random
from datetime import time

def generate_random_time():
    hour = random.randint(8, 17)
    minute = random.randint(0, 59)
    second = random.randint(0, 59)
    return f"{hour:02d}:{minute:02d}:{second:02d}"

def process_csv():
    # Input paths
    input_path = r'C:\flutter_projects\PROYECTO_ASOGUAPO\FACTURAS_GENERADAS.csv'
    output_path = r'C:\flutter_projects\PROYECTO_ASOGUAPO\app\assets\LECTURAS_PILOTO.csv'
    
    # Read FACTURAS_GENERADAS (UTF-16, Tab separated)
    df = pd.read_csv(input_path, encoding='utf-16', sep='\t')
    
    # Select and rename columns
    # LECTURAS_PILOTO columns: 
    # CODIGO_CONCATENADO, NOMBRE_COMPLETO, CEDULA, CELULAR, VEREDA, HISTORICO_NOV, HISTORICO_DIC, FECHA_HISTORICO_DIC, HORA_HISTORICO_DIC
    
    # Handle the reading logic
    # HISTORICO_NOV is LECTURA_ANTERIOR
    # HISTORICO_DIC is LECTURA_ACTUAL
    
    df['HISTORICO_NOV'] = df['LECTURA_ANTERIOR']
    df['HISTORICO_DIC'] = df['LECTURA_ACTUAL']
    
    # Fill based on consumption if one is missing
    # If nov is missing but dic and consumo exist
    mask_nov_missing = df['HISTORICO_NOV'].isna() & df['HISTORICO_DIC'].notna() & df['CONSUMO_M3'].notna()
    df.loc[mask_nov_missing, 'HISTORICO_NOV'] = df['HISTORICO_DIC'] - df['CONSUMO_M3']
    
    # If dic is missing but nov and consumo exist
    mask_dic_missing = df['HISTORICO_DIC'].isna() & df['HISTORICO_NOV'].notna() & df['CONSUMO_M3'].notna()
    df.loc[mask_dic_missing, 'HISTORICO_DIC'] = df['HISTORICO_NOV'] + df['CONSUMO_M3']
    
    # Constant columns
    df['FECHA_HISTORICO_DIC'] = '2026-12-20'
    df['HORA_HISTORICO_DIC'] = df.apply(lambda _: generate_random_time(), axis=1)
    
    # Select final columns
    final_cols = [
        'CODIGO_CONCATENADO', 
        'NOMBRE_COMPLETO', 
        'CEDULA', 
        'CELULAR', 
        'VEREDA', 
        'HISTORICO_NOV', 
        'HISTORICO_DIC', 
        'FECHA_HISTORICO_DIC', 
        'HORA_HISTORICO_DIC'
    ]
    
    # Handle Nulls for output (if they are NaN, make them empty)
    # Actually, to_csv handles NaN as empty by default if we want
    
    # Final cleanup: ensure we only have the required columns
    output_df = df[final_cols].copy()
    
    # helper to format numeric columns avoiding .0
    def format_numeric(val):
        if pd.isna(val):
            return ""
        try:
            # If it's a number, convert to int then string
            return str(int(float(val)))
        except:
            return str(val)

    for col in ['HISTORICO_NOV', 'HISTORICO_DIC', 'CEDULA']:
        output_df[col] = output_df[col].apply(format_numeric)

    # Save to CSV
    output_df.to_csv(output_path, index=False, encoding='utf-8')
    print(f"Processed {len(output_df)} records. Saved to {output_path}")

if __name__ == "__main__":
    process_csv()
