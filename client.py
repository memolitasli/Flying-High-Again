from urllib import response
import requests
import json
BASE = "http://127.0.0.1:5000/"

data=[
    {"userID":"saxSsdsaaa","enlem":"25.1515","boylam":"15.111"},
    {"userID":"saxSsdsaaa","enlem":"25.15215","boylam":"15.111"},
    {"userID":"saxSsdsaaa","enlem":"25.1515","boylam":"15.111"},
    {"userID":"saxSsdsaaa","enlem":"25.1515","boylam":"15.111"}
]

'''
print(response)
print(response.json())
response = requests.delete(BASE+"gorev/saxSsdsaaa")
'''

#for i in range(len(data)):
#    response=requests.post(BASE+"gorev/"+str(i),data[i])
#    print(response)

response = requests.get(BASE+"gorev/xb59jF8n6iONbqfImT6yBdGvZPQ2")

print(response.json())
