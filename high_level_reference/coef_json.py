import json
import numpy as np 
import pywt

var = "db"
dados = {}

for i in range(1,38): 
    var="db"+str(i)
    coef = pywt.Wavelet(var) 
    dados[var]=coef.dec_lo

    
print(dados)    

with open('coef_db.json', 'w', encoding='utf-8') as arquivo:
    json.dump(dados, arquivo, ensure_ascii=False, indent=4)

#coef = pywt.Wavelet('db5')
