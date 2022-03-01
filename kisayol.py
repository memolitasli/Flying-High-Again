#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from math import sin,cos,asin,sqrt,acos,asin,floor
from array import *
from turtle import shape
from matplotlib import collections
from matplotlib.pyplot import step
import numpy as np
from collections import defaultdict
from collections import *


konumlar = [    
    {'enlem':75.1555462,'boylam':148.1548242},
    {'enlem':35.1515462,'boylam':148.1548542},
    {'enlem':35.1545462,'boylam':148.1548542},
    {'enlem':65.1513462,'boylam':128.1528542}
        ]



#konumlar arasındaki mesafeyi km olarak bir matris içerisine aktarıyor
def latLonToKm(konumListe):
    i = 0
    j = 0
    matris = np.empty(shape=(len(konumListe),len(konumListe)))
    for konum in konumListe:
        for konum2 in konumListe:
            if(konum == konum2):
                matris[i][j] = 69.420
            else:
                enlem1Rad = float(konum['enlem'])/(180/3.14)
                boylam1Rad = float(konum['boylam'])/(180/3.14)
                enlem2Rad = float(konum2['enlem'])/(180/3.14)
                boylam2Rad = float(konum2['boylam'])/(180/3.14)
                enlemRadFark = enlem2Rad - enlem1Rad
                boylamRadFark = boylam2Rad - boylam1Rad

                mesafe = 3963.0 * acos(sin(enlem1Rad)*sin(enlem2Rad) + cos(enlem1Rad)*cos(enlem2Rad)*cos(boylamRadFark))
                #cikan sonuc mil olarak cikiyor bu nedenle km ye cevirmek icin  1.609344 ile çarpıyorum
                mesafe = mesafe *  1.609344
                mesafe = round(mesafe,5)
                matris[i][j] = mesafe
            j = j+1
        i = i+1
        j = 0
    print(matris)
    return matris

gelenMatris = latLonToKm(konumlar)

def DFS(matris):
    siraListesi = []
    h = len(matris)
    if h == 0:
        return
    l = len(matris[0])
    ziyaretEdilenler = np.full_like(shape=(len(konumlar),len(konumlar)),dtype=bool,fill_value=False,a=False)
    print(ziyaretEdilenler)
    stack =[]
    stack.append("0,0")
    while(len(stack)!= 0):
        x = stack.pop()
        row = int(x.split(",")[0])
        column=int(x.split(",")[1])
        if row<0 or column<0 or row>=h or column == l or ziyaretEdilenler[row][column]:
            continue
        ziyaretEdilenler[row][column]=True
        siraListesi.append(str(str(row) + " , ") + str(column))
        print(str(matris[row][column]) + " ")
        stack.append(str(row) + ","+str((column - 1)))
        stack.append(str(row) + ","+str((column + 1)))
        stack.append(str((row - 1)) + ","+str((column)))
        stack.append(str((row + 1))+ ","+str((column)))
    donenListe = []
    mesafeList = []
    yol = 0
    donenListe = [siraListesi[i:i + len(konumlar)]for i in range(0,len(siraListesi),len(konumlar))]     
    for i in range(len(donenListe)):
        for j in range(len(konumlar)):
            satir = donenListe[i][j].split(",")[0]
            sutun=donenListe[i][j].split(",")[1]
            yol += matris[int(satir)][int(sutun)]
        mesafeList.append(yol)
        yol = 0
    enKisaYol = min(mesafeList)
    enKisaYolIndex = mesafeList.index(enKisaYol)
    
    return donenListe[enKisaYolIndex]

deneme = [
[666,10.0,30.0,15.0],
[10.0,666,20.0,5.0],
[30.0,20.0,666,1.0],
[15.0,25.0,18.0,666]
]
sonuc = DFS(deneme)
print(sonuc)





